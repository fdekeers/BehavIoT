#!/bin/bash

# Run the BehavIoT pipeline scripts for the second part:
# Feature generation

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs


## Feature extraction
# On decoded traffic
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/idle-2021-decoded/ $DATA_DIR/idle-2021-features/ $NPROCS > $LOGS_DIR/2-feature-generation/1-features-idle.log 2> $LOGS_DIR/2-feature-generation/1-features-idle.error
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/train-decoded/ $DATA_DIR/train-features/ > $LOGS_DIR/2-feature-generation/2-features-train.log 2> $LOGS_DIR/2-feature-generation/2-features-train.error
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/test-decoded/ $DATA_DIR/test-features/ > $LOGS_DIR/2-feature-generation/3-features-test.log 2> $LOGS_DIR/2-feature-generation/3-features-test.error
# On routine dataset
python3 $PIPELINE_DIR/s1_decode_dns_tls.py $INPUT_DIR/routine_dns.txt > $LOGS_DIR/2-feature-generation/4-routine-decode-dns.log 2> $LOGS_DIR/2-feature-generation/4-routine-decode-dns.error
python3 $PIPELINE_DIR/s1_decode_activity.py $INPUT_DIR/routine-dataset.txt $DATA_DIR/routine-decoded/ > $LOGS_DIR/2-feature-generation/5-routine-decode-activity.log 2> $LOGS_DIR/2-feature-generation/5-routine-decode-activity.error
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/routine-decoded/ $DATA_DIR/routine-features/ > $LOGS_DIR/2-feature-generation/6-features-routine.log 2> $LOGS_DIR/2-feature-generation/6-features-routine.error
