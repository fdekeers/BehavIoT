import os
from pathlib import Path
from datetime import datetime

# Useful paths
script_path = Path(os.path.abspath(__file__))  # This script's path
script_dir = script_path.parents[0]            # This script's directory
pfsm_dir = script_path.parents[1]              # This script's parent directory
traces_dir = os.path.join(pfsm_dir, "traces")  # Traces directory


root_feature = os.path.join(traces_dir, "log_routines")
list1 = []
list_of_devices = set()
for csv_file in os.listdir(root_feature):
    # TODO: update dname
    dname = '-'.join(csv_file.split('.')[0].split('-')[1:]) # csv_file[9:-4]
    print(f"dname: {dname}")
    list_of_devices.add(dname)
list_of_devices = list(list_of_devices)
print(list_of_devices)


for csv_file in os.listdir(root_feature):
    # TODO: update dname
    dname = '-'.join(csv_file.split('.')[0].split('-')[1:]) # csv_file[9:-4]
    print(f"dname: {dname}")
    print(dname, csv_file)
    f = open(os.path.join(root_feature, csv_file))

    for line in f:
        if len(line) <= 1 or line.startswith(' ') or line.startswith('0') :
            continue
        else:
            time = ':'.join(line.split(':')[:-1])
            label = line.split(':')[-1]
            if label.endswith('\n'):
                label = label[:-1]
            if label =='unknown':
                continue
            try:
                o1 = datetime.strptime(time[:-1], '%m/%d/%Y, %H:%M:%S.%f')
            except:
                print('Error', dname, time, label)
                # exit(1)
            print(o1, label)

            list1.append(('%s-%s %s'  % (dname,label, str(o1)),o1))

# print(list1)
list1 = sorted(list1,key=lambda x: x[1])
split_time = '10/25/2021, 00:00:00.000005'
list_train = [] 
list_test = []
for x in list1:
    if x[1] <= datetime.strptime(split_time, '%m/%d/%Y, %H:%M:%S.%f'):
        list_train.append(x)
    else:
        list_test.append(x)


# print(list1)
# exit(1)
label = 0
time = 0
with open(os.path.join(traces_dir, "trace_log_may1"), 'w') as off:
    
    traceID = 0
    first_time = 0

    last_time = 0
    for i in list1:
        line = i[0]
        label = line.split()[0]
        d_str = ' '.join(line.split()[1:])
        # print(d_str)
        o = datetime.strptime(d_str, '%Y-%m-%d %H:%M:%S.%f')
        if traceID == 0:
            first_time = o.timestamp()
            traceID += 1
        new_time = o.timestamp() - first_time

        if (new_time > last_time + 60):
        #     traceID +=1 

            off.write('---%s---\n' % d_str)
            last_time = 0
            first_time = o.timestamp()
            new_time = 0
        else:    
            last_time = new_time
        
        # new_time = float(o) - last_time

        off.write(f"{label}, {new_time} \n")
        # off.write('%s \n' % (','.join(['%.3f' %(new_time), (new_line_1+'-'+new_line_2)])))


with open(os.path.join(base_dir, "trace_may1"), 'w') as off:
    
    traceID = 0
    first_time = 0

    last_time = 0
    for i in list1:
        line = i[0]
        label = line.split()[0]
        d_str = ' '.join(line.split()[1:])
        # print(d_str)
        o = datetime.strptime(d_str, '%Y-%m-%d %H:%M:%S.%f')
        if traceID == 0:
            first_time = o.timestamp()
            traceID += 1
        new_time = o.timestamp() - first_time

        if (new_time > last_time + 60):
        #     traceID +=1 

            off.write('------\n' )
            last_time = 0
            first_time = o.timestamp()
            new_time = 0
        else:    
            last_time = new_time
        
        # new_time = float(o) - last_time

        off.write(f"{label}, {new_time} \n")
        # off.write('%s \n' % (','.join(['%.3f' %(new_time), (new_line_1+'-'+new_line_2)])))


with open(os.path.join(traces_dir, "trace_train_may1"), 'w') as off:
    
    traceID = 0
    first_time = 0

    last_time = 0
    for i in list_train:
        line = i[0]
        label = line.split()[0]
        d_str = ' '.join(line.split()[1:])
        # print(d_str)
        o = datetime.strptime(d_str, '%Y-%m-%d %H:%M:%S.%f')
        if traceID == 0:
            first_time = o.timestamp()
            traceID += 1
        new_time = o.timestamp() - first_time

        if (new_time > last_time + 60):
        #     traceID +=1 

            off.write('------\n' )
            last_time = 0
            first_time = o.timestamp()
            new_time = 0
        else:    
            last_time = new_time
        
        # new_time = float(o) - last_time

        off.write(f"{label}, {new_time} \n")
        # off.write('%s \n' % (','.join(['%.3f' %(new_time), (new_line_1+'-'+new_line_2)])))


with open(os.path.join(traces_dir, "trace_test_may1"), 'w') as off:
    
    traceID = 0
    first_time = 0

    last_time = 0
    for i in list_test:
        line = i[0]
        label = line.split()[0]
        d_str = ' '.join(line.split()[1:])
        # print(d_str)
        o = datetime.strptime(d_str, '%Y-%m-%d %H:%M:%S.%f')
        if traceID == 0:
            first_time = o.timestamp()
            traceID += 1
        new_time = o.timestamp() - first_time

        if (new_time > last_time + 60):
        #     traceID +=1 

            off.write('---%s---\n' % d_str)
            last_time = 0
            first_time = o.timestamp()
            new_time = 0
        else:    
            last_time = new_time
        
        # new_time = float(o) - last_time

        off.write(f"{label}, {new_time} \n")
        # off.write('%s \n' % (','.join(['%.3f' %(new_time), (new_line_1+'-'+new_line_2)])))
