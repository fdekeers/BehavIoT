#!/bin/bash

# State Machine builder for BehavIoT

SELF_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
your_root_path="~"
synoptic_dir="$your_root_path/synoptic"
base_dir="$your_root_path/BehavIoT/PFSM"
output_dir="$base_dir/output/jan"
input_dir="$base_dir/traces"
input_file="trace2_sorted"

# # synoptic
# bash synoptic.sh -o output/nism_mar20 --dumpInitialPartitionGraph=True --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True logs/trace

# bash synoptic.sh -o output/nism_apr28 --dumpInitialPartitionGraph=True --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True logs/trace
# bash synoptic.sh -o output/nism_apr28 --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True logs/trace
# bash synoptic.sh -o output/nism_5fold_9 --dumpInvariants=True -r '(?<TYPE>.+),(?<DTIME>.+)$' -s '^------$' --outputCountLabels=True --outputProbLabels=True --outputSupportCount=True --ignoreNFbyInvs=True --supportCountThreshold=2 logs/trace_5fold_train_9

python3 $SELF_DIR/state_machine_read.py $output_dir
