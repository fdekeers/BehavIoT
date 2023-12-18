#!/bin/bash

# Run the BehavIoT pipeline scripts for the fifth part:
# Periodic event inference

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs


## 5. Periodic event inference and filtering
MODEL_DIR=$EVENT_INFERENCE_DIR/model
# 5.1. Train
python3 $PIPELINE_DIR/s5_periodic_filter.py -i $DATA_DIR/idle-2021-train-std/ -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/1-train-idle.log 2> $LOGS_DIR/5-periodic-event-inference/1-train-idle.error
# 5.2. Activity dataset
python3 $PIPELINE_DIR/s5_filter_by_periodic.py -i train -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/2-filter-train.log 2> $LOGS_DIR/5-periodic-event-inference/2-filter-train.error
python3 $PIPELINE_DIR/s5_filter_by_periodic.py -i test -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/3-filter-test.log 2> $LOGS_DIR/5-periodic-event-inference/3-filter-test.error
# 5.3. Routine dataset: timing + model filter
python3 $PIPELINE_DIR/s5_periodic_time_filter.py -i $DATA_DIR/routines-std/ -o $MODEL_DIR/time_filter > $LOGS_DIR/5-periodic-event-inference/4-periodic-filter-routines.log 2> $LOGS_DIR/5-periodic-event-inference/4-periodic-filter-routines.error
python3 $PIPELINE_DIR/s5_filter_by_periodic_after_time.py -i routines -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/5-filter-routines.log 2> $LOGS_DIR/5-periodic-event-inference/5-filter-routines.error
