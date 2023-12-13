#!/bin/bash

# Run the BehavIoT pipeline scripts for the first part:
# Decoding

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs


## Decoding
# Hostname-IP mapping
python3 $PIPELINE_DIR/s1_decode_dns_tls.py $INPUT_DIR/idle_dns.txt > $LOGS_DIR/1-decoding/1-dns-mapping-idle.log 2> $LOGS_DIR/1-decoding/1-dns-mapping-idle.error
python3 $PIPELINE_DIR/s1_decode_dns_tls.py $INPUT_DIR/activity_dns.txt > $LOGS_DIR/1-decoding/2-dns-mapping-activity.log 2> $LOGS_DIR/1-decoding/2-dns-mapping-activity.error
# Run decoding
python3 $PIPELINE_DIR/s1_decode_idle.py $INPUT_DIR/idle-2021.txt $DATA_DIR/idle-2021-decoded/ $NPROCS > $LOGS_DIR/1-decoding/3-decode-idle.log 2> $LOGS_DIR/1-decoding/3-decode-idle.error
python3 $PIPELINE_DIR/s1_decode_activity.py $INPUT_DIR/train.txt $DATA_DIR/train-decoded/ $NPROCS > $LOGS_DIR/1-decoding/4-decode-train.log 2> $LOGS_DIR/1-decoding/4-decode-train.error
python3 $PIPELINE_DIR/s1_decode_activity.py $INPUT_DIR/test.txt $DATA_DIR/test-decoded/ $NPROCS > $LOGS_DIR/1-decoding/4-decode-test.log 2> $LOGS_DIR/1-decoding/4-decode-test.error
