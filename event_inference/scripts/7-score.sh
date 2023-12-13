#!/bin/bash

# Run the BehavIoT pipeline scripts for the seventh part:
# Computing periodic model score

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs


## 7. Periodic model score
python3 $PIPELINE_DIR/periodic_deviation_score.py -i $DATA_DIR/idle-half-train-std/ -o $MODEL_DIR/time_score_newT_train_idle > $LOGS_DIR/7-score/1-deviation-score.log 2> $LOGS_DIR/7-score/1-deviation-score.error
python3 $PIPELINE_DIR/periodic_score_analysis.py $MODEL_DIR/time_score_newT_train_idle $MODEL_DIR/time_score_newT_test_idle > $LOGS_DIR/7-score/2-score-analysis.log 2> $LOGS_DIR/7-score/2-score-analysis.error
