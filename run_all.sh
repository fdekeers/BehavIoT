#!/bin/bash

# Run all experiments for BehavIoT.

# Constants
NPROCS=$(nproc) # Number of processors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )  # This script's path


### Event inference
EVENT_INFERENCE_DIR=$SCRIPT_DIR/event_inference
PIPELINE_DIR=$EVENT_INFERENCE_DIR/pipeline
INPUTS_DIR=$EVENT_INFERENCE_DIR/inputs/2021
DATA_DIR=$EVENT_INFERENCE_DIR/data
LOGS_DIR=$EVENT_INFERENCE_DIR/logs

## 1. Decoding
# 1.1. Hostname-IP mapping
python3 $PIPELINE_DIR/s1_decode_dns_tls.py $INPUTS_DIR/idle_dns.txt > $LOGS_DIR/1-decoding/1-dns-mapping-idle.log 2>/dev/null
python3 $PIPELINE_DIR/s1_decode_dns_tls.py $INPUTS_DIR/activity_dns.txt > $LOGS_DIR/1-decoding/2-dns-mapping-activity.log 2>/dev/null
# 1.2. Run decoding
python3 $PIPELINE_DIR/s1_decode_idle.py $INPUTS_DIR/idle-2021.txt $DATA_DIR/idle-2021-decoded/ $NPROCS > $LOGS_DIR/1-decoding/3-decode-idle.log 2>/dev/null
python3 $PIPELINE_DIR/s1_decode_activity.py $INPUTS_DIR/train.txt $DATA_DIR/train-decoded/ $NPROCS > $LOGS_DIR/1-decoding/4-decode-train.log 2>/dev/null
python3 $PIPELINE_DIR/s1_decode_activity.py $INPUTS_DIR/test.txt $DATA_DIR/test-decoded/ $NPROCS > $LOGS_DIR/1-decoding/4-decode-test.log 2>/dev/null

## 2. Feature extraction
# 2.1. On decoded traffic
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/idle-2021-decoded/ $DATA_DIR/idle-2021-features/ > $LOGS_DIR/2-feature-generation/1-features-idle.log 2>/dev/null
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/train-decoded/ $DATA_DIR/train-features/ > $LOGS_DIR/2-feature-generation/2-features-train.log 2>/dev/null
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/test-decoded/ $DATA_DIR/test-features/ > $LOGS_DIR/2-feature-generation/3-features-test.log 2>/dev/null
# 2.2. On routine dataset
python3 $PIPELINE_DIR/s1_decode_dns_tls.py $INPUT_DIR/routine_dns.txt > $LOGS_DIR/2-feature-generation/4-routine-decode-dns.log 2>/dev/null
python3 $PIPELINE_DIR/s1_decode_activity.py $INPUT_DIR/routine-dataset.txt $DATA_DIR/routine-decoded/ > $LOGS_DIR/2-feature-generation/5-routine-decode-activity.log 2>/dev/null
python3 $PIPELINE_DIR/s2_get_features.py $DATA_DIR/routine-decoded/ $DATA_DIR/routine-features/ > $LOGS_DIR/2-feature-generation/6-features-routine.log 2>/dev/null
# 2.3. On uncontrolled dataset
# Impossible, since this dataset cannot be shared

## 3. Periodic traffic extraction
PERIOD_EXTRACTION_DIR=$EVENT_INFERENCE_DIR/period_extraction
python3 $PERIOD_EXTRACTION_DIR/periodicity_inference.py > $LOGS_DIR/3-period-extraction/1-periodicity-inference.log 2>/dev/null
python3 $PERIOD_EXTRACTION_DIR/fingerprint_generation.py > $LOGS_DIR/3-period-extraction/2-fingerprint-generation.log 2>/dev/null

## 4. Preprocessing
python3 $PIPELINE_DIR/s4_preprocess_feature_new.py -i $DATA_DIR/idle-2021-features/ -o $DATA_DIR/idle/ > $LOGS_DIR/4-preprocessing/1-preprocess-idle.log 2>/dev/null
python3 $PIPELINE_DIR/s4_preprocess_feature_applyonly.py -i $DATA_DIR/uncontrolled-features/ -o $DATA_DIR/uncontrolled/ > $LOGS_DIR/4-preprocessing/2-preprocess-uncontrolled.log 2>/dev/null

## 5. Periodic event inference and filtering
MODEL_DIR=$EVENT_INFERENCE_DIR/model
# 5.1. Train
python3 $PIPELINE_DIR/s5_periodic_filter.py -i $DATA_DIR/idle-2021-train-std/ -o $MODEL_DIR/filter_apr20 > $LOGS_DIR/5-periodic-event-inference/1-train-idle.log 2>/dev/null
# 5.2. Activity dataset
python3 $PIPELINE_DIR/s5_filter_by_periodic.py -i train -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/2-filter-train.log 2>/dev/null
python3 $PIPELINE_DIR/s5_filter_by_periodic.py -i test -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/3-filter-test.log 2>/dev/null
# 5.3. Routine dataset: timing + model filter
python3 $PIPELINE_DIR/s5_periodic_time_filter.py -i $DATA_DIR/routines-std/ -o $MODEL_DIR/time_filter > $LOGS_DIR/5-periodic-event-inference/4-periodic-filter-routines.log 2>/dev/null
python3 $PIPELINE_DIR/s5_filter_by_periodic_after_time.py -i routines -o $MODEL_DIR/filter > $LOGS_DIR/5-periodic-event-inference/5-filter-routines.log 2>/dev/null
# 5.4. Uncontrolled dataset: timing + model filter
# Impossible, since this dataset cannot be shared

## 6. User event inference
# With hostname
python3 $PIPELINE_DIR/s6_activity_fingerprint.py -i $DATA_DIR/train-filtered-std/ -o $MODEL_DIR/fingerprint/ > $LOGS_DIR/6-user-event-inference/1-train-fingerprint.log 2>/dev/null
python3 $PIPELINE_DIR/s6_binary_model_whostname.py -i $DATA_DIR/train-filtered-std/ -o $MODEL_DIR/binary > $LOGS_DIR/6-user-event-inference/2-train-binary-whostname.log 2>/dev/null
python3 $PIPELINE_DIR/s6_binary_predict_whostname.py -i $DATA_DIR/routines-filtered-std/ -o $MODEL_DIR/binary > $LOGS_DIR/6-user-event-inference/3-predict-routines-binary-whostname.log 2>/dev/null
# Without hostname
#python3 $PIPELINE_DIR/s6_binary_model.py -i $DATA_DIR/train-filtered-std/ -o $MODEL_DIR/binary > $LOGS_DIR/6-user-event-inference/2-train-binary.log 2>/dev/null
#python3 $PIPELINE_DIR/s6_binary_predict.py -i $DATA_DIR/routines-filtered-std/ -o $MODEL_DIR/binary > $LOGS_DIR/6-user-event-inference/3-predict-routines-binary.log 2>/dev/null

## 7. Periodic model score
python3 $PIPELINE_DIR/periodic_deviation_score.py -i $DATA_DIR/idle-half-train-std/ -o $MODEL_DIR/time_score_newT_train_idle > $LOGS_DIR/7-score/1-deviation-score.log 2>/dev/null
python3 $PIPELINE_DIR/periodic_score_analysis.py $MODEL_DIR/time_score_newT_train_idle $MODEL_DIR/time_score_newT_test_idle > $LOGS_DIR/7-score/2-score-analysis.log 2>/dev/null


### PFSM
# TODO

### Behavioral analysis
# TODO
