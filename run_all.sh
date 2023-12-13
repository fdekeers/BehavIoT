#!/bin/bash

# Run all experiments for BehavIoT.

# Constants
NPROCS=$(nproc) # Number of processors
SELF_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path
# Useful directories
EVENT_INFERENCE_DIR=$SELF_DIR/event_inference
SCRIPTS_DIR=$EVENT_INFERENCE_DIR/scripts


### Event inference

## 1. Decoding
#$SCRIPTS_DIR/1-decoding.sh

## 2. Feature extraction
#$SCRIPTS_DIR/2-feature-generation.sh

## 3. Periodic traffic extraction
#$SCRIPTS_DIR/3-period-extraction.sh

## 4. Preprocessing
$SCRIPTS_DIR/4-preprocessing.sh

## 5. Periodic event inference and filtering
$SCRIPTS_DIR/5-periodic-event-inference.sh

## 6. User event inference
$SCRIPTS_DIR/6-user-event-inference.sh

## 7. Periodic model score
$SCRIPTS_DIR/7-score.sh


### PFSM
# TODO

### Behavioral analysis
# TODO
