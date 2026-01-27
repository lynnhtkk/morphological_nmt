#!/bin/bash

# !! Should be run from the root directory (BPC_NLP_PROJECT) !!
src=fi
tgt=en

# Path Variables
data_dir="data/preprocessed"
bpe_scripts="tools/subword-nmt/subword_nmt"

# Dataset Prefixes
train=train
dev=dev
test=test

# Loop through experiments (10k and 20k)
for experiment in "10000 pipeline_A_10k" "20000 pipeline_A_20k"; do
    set -- $experiment
    bpe_ops=$1
    output_dir=$2

    # Create output directories
    # mkdir -p "$output_dir/models" "$output_dir/data"

    # Output BPE model (the merge rules)
    bpe_code_file="$output_dir/models/bpe-codes.$bpe_ops"

    # 1. Learn the BPE Segmentation on the concatenation of training text, and get vocabulary for each language
    python3 $bpe_scripts/learn_joint_bpe_and_vocab.py \
        --input "$data_dir/$train.tc.$src" "$data_dir/$train.tc.$tgt" \
        -s $bpe_ops \
        -o $bpe_code_file \
        --write-vocabulary "$output_dir/models/vocab.$src" "$output_dir/models/vocab.$tgt"

    # 2. Apply BPE with Vocabulary Filtering
    for prefix in $train $test $dev; do
        for lang in $src $tgt; do
            python3 $bpe_scripts/apply_bpe.py \
                -c $bpe_code_file \
                --vocabulary "$output_dir/models/vocab.$lang" \
                --vocabulary-threshold 50 \
                < "$data_dir/$prefix.tc.$lang" \
                > "$output_dir/data/$prefix.bpe.$lang"
        done
    done
done