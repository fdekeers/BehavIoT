import os
from pathlib import Path
from datetime import datetime

# Useful paths
script_path = Path(os.path.abspath(__file__))  # This script's path
script_dir = script_path.parents[0]            # This script's directory
pfsm_dir = script_path.parents[1]              # This script's parent directory


"""
Build the log files for Synoptic
"""
base_dir = os.path.join(cdf_dir, "traces")
root_feature = os.path.join(base_dir, "log_uncontrolled")
list1 = []
for csv_file in os.listdir(root_feature):
    # TODO: update dname
    dname = '-'.join(csv_file.split('.')[0].split('-')[1:]) # csv_file[9:-4]
    print(f"dname: {dname}")
    print(dname, csv_file)
    exit()

    file_path = os.path.join(root_feature, csv_file)
    f = open(file_path)

    for line in f:
        if len(line) <= 1 or line.startswith(' ') : # or line.startswith('1') 
            continue
        else:
            time = ':'.join(line.split(':')[:-1])
            label = line.split(':')[-1]
            if label.endswith('\n'):
                label = label[:-1]
            try:
                o1 = datetime.strptime(time[:-1], '%m/%d/%Y, %H:%M:%S.%f')
            except:
                print('Error', dname, time, label)
                # exit(1)
            print(o1, label)

            list1.append(('%s-%s %s'  % (dname,label, str(o1)),o1))
    
    f.close()

# print(list1)
list1 = sorted(list1,key=lambda x: x[1])

label = 0
time = 0
with open(os.path.join(base_dir, "unctrl_feb"), 'w') as off:
    
    traceID = 0
    first_time = 0

    last_time = 0
    # last_time_str = 0
    for i in list1:
        line = i[0]
        label = line.split()[0]
        d_str = ' '.join(line.split()[1:])
        # print(d_str)
        o = datetime.strptime(d_str, '%Y-%m-%d %H:%M:%S.%f')
        if traceID == 0:
            first_time = o.timestamp()
            off.write('---%s---\n' % d_str)
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
        
        off.write('%s, %s \n' % (label, new_time))

