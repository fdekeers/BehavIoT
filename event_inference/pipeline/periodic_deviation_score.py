import warnings
import utils
import os
from pathlib import Path
import sys
import argparse
import numpy as np
import pandas as pd
import time
from multiprocessing import Pool
import Constants as c

warnings.simplefilter("ignore", category=DeprecationWarning)

# Useful paths
script_path = Path(os.path.abspath(__file__))                # This script's path
script_dir = script_path.parents[0]                          # This script's directory
event_inference_dir = script_path.parents[1]                 # This script's parent directory

num_pools = 1

cols_feat = [ "meanBytes", "minBytes", "maxBytes", "medAbsDev",
             "skewLength", "kurtosisLength", "meanTBP", "varTBP", "medianTBP", "kurtosisTBP",
             "skewTBP", "network_total", "network_in", "network_out", "network_external", "network_local",
            "network_in_local", "network_out_local", "meanBytes_out_external",
            "meanBytes_in_external", "meanBytes_out_local", "meanBytes_in_local", "device", "state", "event", "start_time", "protocol", "hosts"]


model_list = []
root_output = ''
dir_tsne_plots = ''
root_feature = ''
root_model = ''

def print_usage(is_error):
    print(c.EVAL_MOD_USAGE, file=sys.stderr) if is_error else print(c.EVAL_MOD_USAGE)
    exit(is_error)


def main():
    # test()
    global  root_output, dir_tsne_plots, model_list , root_feature, root_model

    # Parse Arguments
    parser = argparse.ArgumentParser(usage=c.EVAL_MOD_USAGE, add_help=False)
    parser.add_argument("-i", dest="root_feature", default="")
    parser.add_argument("-o", dest="root_model", default="")

    parser.add_argument("-h", dest="help", action="store_true", default=False)
    args = parser.parse_args()

    if args.help:
        print_usage(0)

    print("Running %s..." % c.PATH)

    # Error checking command line args
    root_feature = args.root_feature
    root_model = args.root_model
    # dbscan_eps = args.eps
    errors = False
    #check -i in features
    if root_feature == "":
        errors = True
        print(c.NO_FEAT_DIR, file=sys.stderr)
    elif not os.path.isdir(root_feature):
        errors = True
        print(c.INVAL % ("Features directory", root_feature, "directory"), file=sys.stderr)
    else:
        if not os.access(root_feature, os.R_OK):
            errors = True
            print(c.NO_PERM % ("features directory", root_feature, "read"), file=sys.stderr)
        if not os.access(root_feature, os.X_OK):
            errors = True
            print(c.NO_PERM % ("features directory", root_feature, "execute"), file=sys.stderr)

    #check -o out models
    if root_model == "":
        errors = True
        print(c.NO_MOD_DIR, file=sys.stderr)
    elif os.path.isdir(root_model):
        if not os.access(root_model, os.W_OK):
            errors = True
            print(c.NO_PERM % ("model directory", root_model, "write"), file=sys.stderr)
        if not os.access(root_model, os.X_OK):
            errors = True
            print(c.NO_PERM % ("model directory", root_model, "execute"), file=sys.stderr)



    if errors:
        print_usage(1)
    #end error checking

    print("Input files located in: %s\nOutput files placed in: %s" % (root_feature, root_model))

    os.makedirs(root_model, exist_ok=True)
    train_models()


def train_models():
    global root_feature, root_model, root_output, dir_tsne_plots
    """
    Scan feature folder for each device
    """
    print('root_feature: %s' % root_feature)
    print('root_model: %s' % root_model)
    print('root_output: %s' % root_output)
    lfiles = []
    lparas = []
    ldnames = []

    random_state = 422
    print("random_state:", random_state)
    for csv_file in os.listdir(root_feature):
        if csv_file.endswith('.csv'):
            print(csv_file)
            train_data_file = os.path.join(root_feature, csv_file)
            dname = csv_file[:-4]
            lparas.append((train_data_file, dname, random_state))
    num_pools = 12
    p = Pool(num_pools)
    t0 = time.time()
    list_results = []

    list_results = p.map(eid_wrapper, lparas)

    total_left = 0
    total_flow = 0
    for i in list_results:
        total_left += i[0]
        total_flow += i[1]

    with open(os.path.join(root_model,'results.txt'),'a+') as f:
        f.write('\nTotal: %d, %d\n' % (total_left, total_flow))
    t1 = time.time()
    print('Time to train all models for %s devices using %s threads: %.2f' % (len(lparas),num_pools, (t1 - t0)))
    # p.map(target=eval_individual_device, args=(lfiles, ldnames))


def eid_wrapper(a):
    return eval_individual_device(a[0], a[1], a[2])


def eval_individual_device(train_data_file, dname, random_state, specified_models=None):
    global root_feature, root_model, root_output, dir_tsne_plots

    warnings.simplefilter("ignore", category=DeprecationWarning)
    warnings.simplefilter("ignore", category=FutureWarning)

    """
    Get period from fingerprinting files
    """
    periodic_tuple = []
    tmp_host_set = set()
    try:
        fingerprint_file = os.path.join(event_inference_dir, "period_extraction", "freq_period", "fingerprints", f"{dname}.txt")
        with open(fingerprint_file, 'r') as file:
            for line in file:
                tmp = line.split()
                # print(tmp)
                try:
                    tmp_proto = tmp[0]
                    tmp_host = tmp[1]
                    tmp_period = tmp[2]
                except:
                    print(tmp)
                    exit(1)
                if tmp_host == '#' or tmp_host  == ' ':
                    tmp_host = ''
                periodic_tuple.append((tmp_host, tmp_proto, tmp_period))

                
                tmp_host_set.add((tmp_host,tmp_proto))

    except:
        print( 'unable to read fingerprint file')
        return
    print(dname, periodic_tuple)
    

    print('loading test data')

    test_data = pd.read_csv(train_data_file)  # idle-2021-test-std-2s
    test_data = test_data.sort_values('start_time')
    test_feature = test_data.drop(['device', 'state', 'event', 'start_time', 'protocol', 'hosts'], axis=1).fillna(-1)
    test_data_numpy = np.array(test_data)
    test_feature = np.array(test_feature)
    test_timestamp = np.array(test_data['start_time'].fillna('').values)
    test_protocols = test_data['protocol'].fillna('').values
    test_hosts = test_data['hosts'].fillna('').values
    test_protocols = utils.protocol_transform(test_protocols)

    for i in range(len(test_hosts)):
        if test_hosts[i] != '' and test_hosts[i] != None:
            try:
                tmp = test_hosts[i].split(';')
            except:
                print(test_hosts[i])
                exit(1)
            test_hosts[i] = tmp[0]
        if test_hosts[i] == None:
            test_hosts[i] == 'non'
        test_hosts[i] = test_hosts[i].lower()



    events = test_data['event'].fillna('').values
    len_test_before = len(test_feature)
    num_of_event = len(set(events))


    print('testing data len: ', len_test_before)
    if len_test_before == 0:
        return [0,0]
    mac_dic = utils.read_mac_address()
    filter_dns = []
    for i in range(len(test_feature)):
        if (test_hosts[i] == 'multicast' or  test_protocols[i] == 'MDNS' 
             or test_protocols[i] == 'SSDP'):
            filter_dns.append(False)
        elif test_hosts[i] in mac_dic or ':' in test_hosts[i] or '192' in test_hosts[i]:
            filter_dns.append(False)
        else:
            filter_dns.append(True)
        if dname=='wink-hub2' and test_hosts[i]=='3.90.178.36':
            test_hosts[i] = '*.compute-1.amazonaws.com'
        if dname=='wyze-cam' and test_hosts[i]=='45.56.113.17':
            test_hosts[i] = '*.ip.linodeusercontent.com'
    test_feature = test_feature[filter_dns]
    test_hosts = test_hosts[filter_dns]
    test_protocols = test_protocols[filter_dns]
    test_timestamp = test_timestamp[filter_dns]
    # y_labels_test = y_labels_test[filter_dns]
    test_data_numpy = test_data_numpy[filter_dns]

    log_time_dir = os.path.join(root_model, 'time_logs')
    os.makedirs(log_time_dir, exist_ok=True)

    log_dir = os.path.join(root_model, 'logs')
    os.makedirs(log_dir, exist_ok=True)

    with open(os.path.join(log_dir, f"{dname}.txt"),'w+') as fff:
        fff.write('===================\n' )
    ## For each tuple: 
   
    f = open(os.path.join(log_time_dir, f"{dname}.txt"),'w+')

   
    gone_tuple = {}
    res_left = 0
    res_filtered = 0
    # for loop for each tup
    for tup in periodic_tuple:
        tmp_host = tup[0]
        tmp_proto = tup[1]
        cur_period = float(tup[2])
        # if tmp_host == '':
            # continue
        if cur_period > 7200:
            continue
        print('------%s------' %dname)
        print(tmp_proto, tmp_host)
        f.write('------%s %s %d------\n' % (tmp_host, tmp_proto, cur_period))
        if tmp_proto == 'DNS' or tmp_proto == 'NTP':
            continue
        
        
        print("predicting by trained_model")
        print('Test len before:',len(test_feature))
        filter_test = []
        matched_suffix = False
        for i in range(len(test_feature)):
            
            if tmp_host.startswith('*'):
                matched_suffix = test_hosts[i].endswith(tmp_host[2:])
                if matched_suffix==False and tmp_host=='*.compute.amazonaws.com':
                    if test_hosts[i].endswith('.compute-1.amazonaws.com'):
                        matched_suffix =True
            else:
                matched_suffix = False
            if (test_hosts[i] == tmp_host or matched_suffix) and test_protocols[i] == tmp_proto:
                filter_test.append(True)    # for current (host + protocol)
            else:
                filter_test.append(False)
        
        test_feature_part = test_feature[filter_test]
        test_timestamp_part = test_timestamp[filter_test]
        # events_part = events[filter_test]
        
        # no matched, bg pattern has changed  
        if len(test_feature_part) == 0:
            gone_tuple[tup] = 0
            continue
        print(test_feature_part.shape)
        
        
        ## Matching: 
        y_new = []
        print('Current Period:', cur_period)
        print('Length:', len(test_timestamp_part))
        
        test_timestamp_part_int = list(map(round,test_timestamp_part))
        test_timestamp_part_int_abs = [number - test_timestamp_part_int[0] for number in test_timestamp_part_int]
        test_timestamp_part = list(map(float,test_timestamp_part))

        # multiplier = [2,3]
        
        
        double_period_dic = {'a1piwaqdydua5q.iot.us-east-1.amazonaws.com': [40, 19, 50], 
        'avs-alexa-4-na.amazon.com':[30], 
        'api.amazon.com':[88400], 
        'spectrum.s3.amazonaws.com':[129], 
        'a1nvlh0fc0asuq.iot.us-east-1.amazonaws.com': [1800],  # ikea-hub
        'mqtt-us.meross.com': [121], # meross
        'weather.nest.com': [2400], # nest-tstat
        'dc-na04-useast2.connect.smartthings.com': [300], # smartthings-hub
        '*.linksys.pool.ntp.org': [1200], # t-wemo-plug
        'pool.ntp.org': [3600]
         }

        for i in range(len(test_timestamp_part)):
            if i ==0:
                y_new.append(1)
                continue
            
            deviation_true = False
            # Good with period 
            # 1. the time diff is 2s within the period
            # 2. the time diff is within the diff range of (+/-)0.05% period
            # 3. less than the period. 
            # monitor only detects the significant deviation of bg traffic, not small turbulance 

            if (abs(float(test_timestamp_part[i] - test_timestamp_part[i-1] - cur_period)) <= 1): 
                y_new.append(1)
            elif (float(test_timestamp_part[i] - test_timestamp_part[i-1] - ( cur_period)) <= 0):
                y_new.append(0)
            else:
                deviation_true = True
            
             # double / changed period
            if deviation_true and tmp_host in double_period_dic.keys():
                # print('Double: ', tmp_host)
                matched_tmp = False
                for ddd in double_period_dic[tmp_host]:
                    if (abs(float(test_timestamp_part[i] - test_timestamp_part[i-1] - ddd)) <= 1):
                        # (abs(float(test_timestamp_part[i] - test_timestamp_part[i-1] - ddd)) <= (0.05 * ddd))):
                        # or 
                        # (abs(float(test_timestamp_part[i] - test_timestamp_part[i-1])) <= (0.15 * ddd))
                        #
                        y_new.append(1)
                        matched_tmp = True
                        break
                    elif (float(test_timestamp_part[i] - test_timestamp_part[i-1]-cur_period ) >=0 and float(test_timestamp_part[i] - test_timestamp_part[i-1] - ddd) <= 0):   # max(300, )
                        # float(test_timestamp_part[i] - test_timestamp_part[i-1] - ddd) <= 0):
                        # f.write('Big diff: %d, %.2f, %d \n' % (test_timestamp_part[i]-test_timestamp_part[i-1], abs(float(test_timestamp_part[i] - test_timestamp_part[i-1])), test_timestamp_part[i]))
                        y_new.append(0)
                        matched_tmp = True
                        break

                if matched_tmp == False:
                    deviation_true = True
                else:
                    cur_period = ddd
                    deviation_true = False
            
            deviation_true = True
            if deviation_true:

                if (float(test_timestamp_part[i] - test_timestamp_part[i-1]) >= cur_period):
                    f.write('Anomaly large diff: %.2f, %d, %d, %d \n' % ((test_timestamp_part[i]-test_timestamp_part[i-1]-cur_period)/cur_period ,test_timestamp_part[i]-test_timestamp_part[i-1], (abs((float(test_timestamp_part[i] - test_timestamp_part[i-1])/ cur_period) - round(float(test_timestamp_part[i] - test_timestamp_part[i-1])/ cur_period))), test_timestamp_part[i]))

                    y_new.append(-1)
                else:
                    f.write('Anomaly diff: %.5f,%d, %d, %d \n' % (min(test_timestamp_part[i]-test_timestamp_part[i-1], cur_period-test_timestamp_part[i]+test_timestamp_part[i-1])/cur_period , test_timestamp_part[i]-test_timestamp_part[i-1], (abs((float(test_timestamp_part[i] - test_timestamp_part[i-1])/ cur_period) - round(float(test_timestamp_part[i] - test_timestamp_part[i-1])/ cur_period))), test_timestamp_part[i]))

                    y_new.append(-2)
            else:
                f.write('Normal \n')
        # f.write('Normal \n')
        print('Current Period:', cur_period)
        count_left = 0
        count_big_but_not_enough = 0
        event_after = set()

        filter_list = []
        count_large_deviation = 0
        count_small_deviation = 0
        try:
            if len(y_new) < 1:
                continue
        except:
            continue
        for i in range(len(y_new)):
            if y_new[i] < 0:  
                event_after.add(y_new[i])
                filter_list.append(True)
                count_left += 1
                if y_new[i] == -1:
                    count_large_deviation += 1
                elif y_new[i] == -2:
                    count_small_deviation += 1

            elif y_new[i] == 0:
                count_big_but_not_enough += 1
                filter_list.append(False)   # periodic traffic
            else:
                filter_list.append(False)   # periodic traffic
        # activity_feature = test_feature_part[filter_list]
        if len(filter_list) != len(y_new):
            exit(1)
        count_tmp = 0
        for i in range(len(filter_test)):
            if filter_test[i] == False:
                filter_test[i] = True

            elif filter_test[i] == True: # true, (proto, host)
                if filter_list[count_tmp] == False: # filter
                    filter_test[i] = False
                count_tmp += 1
            else:
                exit(1)


        test_feature = test_feature[filter_test]
        test_hosts = test_hosts[filter_test]
        test_protocols = test_protocols[filter_test]
        # events = events[filter_test]
        test_timestamp = test_timestamp[filter_test]
        # y_labels_test = y_labels_test[filter_test]
        test_data_numpy = test_data_numpy[filter_test]

        
        res_left += count_left
        res_filtered += test_feature_part.shape[0] - count_left
        print("count_left" , count_left, test_feature_part.shape[0] , count_left/test_feature_part.shape[0])
        print('Test len after:',len(test_feature))
        print('-------------')

        """
        Save the model / logs
        """
        log_dir = os.path.join(root_model, 'logs')


        with open(os.path.join(log_dir, f"{dname}.txt"), 'a+') as fff:
            fff.write(f"{tmp_proto} {tmp_host}: ")
            fff.write('\nFlows left (deviation): %d (%d | %d), (%d) %d %2f\n\n' % (count_left,count_large_deviation, count_small_deviation, count_big_but_not_enough, test_feature_part.shape[0], count_left/test_feature_part.shape[0] ))

    f.close()

    mac_dic = utils.read_mac_address()
    host_protocol_dic = {} # host and protocl tuple remained
    for i in range(len(test_feature)):
        if ((test_hosts[i], test_protocols[i]) not in host_protocol_dic):
            host_protocol_dic[(test_hosts[i], test_protocols[i])] = 1
        else:
            host_protocol_dic[(test_hosts[i], test_protocols[i])] += 1
    with open(os.path.join(log_dir,'%s.txt' % dname),'a+') as f: # logs
        
        f.write('\n--------DIFF--------\n')
        
        print(host_protocol_dic)
        print(periodic_tuple)
        count_new = 0
        
        # non-periodic (no match from the fingerprint files generated by periodic inference)
        for k, v in host_protocol_dic.items():
            if k[1] == 'DNS' or k[1] == 'NTP' or k[1] == 'DHCP' or k[1] == 'MDNS':
                continue
            if k[0] in mac_dic or k[0]=='multicast' or ':' in k[0] or '192' in k[0]:
                continue
            matched = False
            
            for fingerprint_tuple in periodic_tuple:
                tmp_host = fingerprint_tuple[0]
                tmp_proto = fingerprint_tuple[1]
                
                if (k[0] == tmp_host or (tmp_host.startswith('*') and k[0].endswith(tmp_host[1:]))) and k[1] == tmp_proto:
                    matched = True 

            if not matched:
                f.write('\n%s %s\n' % ( k[0], k[1]))
                count_new += 1
        
        f.write('----NEW: %d----\n' % count_new)

        
        count_gone = 0
        print(gone_tuple)
        # no certain tuple anymore 
        for k in gone_tuple.keys():
            if k[1] == 'DNS' or k[1] == 'NTP' or k[1] == 'DHCP' or k[1] == 'MDNS':
                continue
            if k[0] in mac_dic or k[0]=='multicast' or ':' in k[0] or '192' in k[0]:
                continue
            f.write('\n%s %s\n' % (k[0], k[1]))
            count_gone += 1

        f.write('----GONE: %d----\n' % count_gone)

        f.write('----Remained----\n')
        for k, v in host_protocol_dic.items():
            f.write('\n%s %s: %d\n' % (k[0], k[1], v))

    """
    Save
    """
    print('Flows left: ', len(test_feature)/len_test_before,len(test_feature), len_test_before)
    print('Activity left: ',len(set(test_data_numpy[:,-4]))/num_of_event, len(set(test_data_numpy[:,-4])), num_of_event)
    with open(os.path.join(root_model,'results.txt'),'a+') as f:
        f.write('%s' % dname)
        f.write('\nFlows left: %2f %d %d' % (len(test_feature)/len_test_before,len(test_feature), len_test_before))
        f.write('\nActivity left: %2f %d %d \n\n' % (len(set(test_data_numpy[:,-4]))/num_of_event, len(set(test_data_numpy[:,-4])), num_of_event))
    test_feature = pd.DataFrame(test_data_numpy, columns=cols_feat) # use this only when processing std data 

    return [len(test_feature), len_test_before]



if __name__ == '__main__':
    main()
    num_pools = 12

