#!/bin/bash

# Run the BehavIoT pipeline scripts for the fourth part:
# Data preprocessing

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs


## Preprocessing
python3 $PIPELINE_DIR/s4_preprocess_feature_new.py -i $DATA_DIR/idle-2021-features/ -o $DATA_DIR/idle/ > $LOGS_DIR/4-preprocessing/1-preprocess-idle.log 2> $LOGS_DIR/4-preprocessing/1-preprocess-idle.error
python3 $PIPELINE_DIR/s4_preprocess_feature_applyonly.py -i $DATA_DIR/uncontrolled-features/ -o $DATA_DIR/uncontrolled/ > $LOGS_DIR/4-preprocessing/2-preprocess-uncontrolled.log 2> $LOGS_DIR/4-preprocessing/2-preprocess-uncontrolled.error
