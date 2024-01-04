#!/bin/bash

# State Machine builder for BehavIoT

SELF_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
your_root_path="/home/user"
synoptic_dir="$your_root_path/synoptic"
base_dir="$SELF_DIR/.."
input_dir="$base_dir/traces"
output_dir="$base_dir/output"
mkdir -p $output_dir
logs_dir="$base_dir/logs"
mkdir -p $logs_dir


# 1. Build PFSM with Synoptic
cd $synoptic_dir
bash ./synoptic.sh -o $output_dir/pfsm --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True --supportCountThreshold=2 $input_dir/trace_may1 > $logs_dir/1-build-pfsm.log 2> $logs_dir/1-build-pfsm.error

# bash synoptic.sh -o output/nism_mar20 --dumpInitialPartitionGraph=True --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True logs/trace
# bash synoptic.sh -o output/nism_apr28 --dumpInitialPartitionGraph=True --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True logs/trace
# bash synoptic.sh -o output/nism_apr28 --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True logs/trace
# bash synoptic.sh -o output/nism_5fold_9 --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True --supportCountThreshold=2 logs/trace_5fold_train_9


# 2. Read PFSM
cd $SELF_DIR
PFSM_FILE=$output_dir/pfsm.dot
TRACE_FILE=$input_dir/trace_may1
python3 $SELF_DIR/state_machine_read.py $PFSM_FILE $TRACE_FILE > $logs_dir/2-read-pfsm.log 2> $logs_dir/2-read-pfsm.error
