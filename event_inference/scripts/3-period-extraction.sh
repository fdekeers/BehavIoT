#!/bin/bash

# Run the BehavIoT pipeline scripts for the third part:
# Period extraction

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SCRIPT_DIR/..
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUT_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs


## Periodic traffic extraction
PERIOD_EXTRACTION_DIR=$EVENT_INFERENCE_DIR/period_extraction
python3 $PERIOD_EXTRACTION_DIR/periodicity_inference.py > $LOGS_DIR/3-period-extraction/1-periodicity-inference.log 2> $LOGS_DIR/3-period-extraction/1-periodicity-inference.error
python3 $PERIOD_EXTRACTION_DIR/fingerprint_generation.py > $LOGS_DIR/3-period-extraction/2-fingerprint-generation.log 2> $LOGS_DIR/3-period-extraction/2-fingerprint-generation.error
