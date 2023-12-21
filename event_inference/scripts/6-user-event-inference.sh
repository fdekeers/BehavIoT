#!/bin/bash

# Run the BehavIoT pipeline scripts for the sixth part:
# User event inference

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs
MODEL_DIR=$EVENT_INFERENCE_DIR/model


## 6. User event inference
python3 $PIPELINE_DIR/s6_activity_fingerprint.py -i $DATA_DIR/train-filtered-std/ -o $MODEL_DIR/fingerprint/ > $LOGS_DIR/6-user-event-inference/1-train-fingerprint.log 2> $LOGS_DIR/6-user-event-inference/1-train-fingerprint.error
# With hostname
python3 $PIPELINE_DIR/s6_binary_model_whostname.py -i $DATA_DIR/train-filtered-std/ -o $MODEL_DIR/binary-whostname > $LOGS_DIR/6-user-event-inference/2-train-binary-whostname.log 2> $LOGS_DIR/6-user-event-inference/2-train-binary-whostname.error
python3 $PIPELINE_DIR/s6_binary_predict_whostname.py -i $DATA_DIR/routines-filtered-std/ -o $MODEL_DIR/binary-whostname > $LOGS_DIR/6-user-event-inference/3-predict-routines-binary-whostname.log 2> $LOGS_DIR/6-user-event-inference/3-predict-routines-binary-whostname.error
# Without hostname
#python3 $PIPELINE_DIR/s6_binary_model.py -i $DATA_DIR/train-filtered-std/ -o $MODEL_DIR/binary > $LOGS_DIR/6-user-event-inference/2-train-binary.log 2> $LOGS_DIR/6-user-event-inference/2-train-binary.error
#python3 $PIPELINE_DIR/s6_binary_predict.py -i $DATA_DIR/routines-filtered-std/ -o $MODEL_DIR/binary > $LOGS_DIR/6-user-event-inference/3-predict-routines-binary.log 2> $LOGS_DIR/6-user-event-inference/3-predict-routines-binary.error
