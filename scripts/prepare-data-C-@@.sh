#!/bin/bash

# !! Should be run from the root directory (BPC_NLP_PROJECT) !!
src=fi
tgt=en

# Dataset Prefixes
train=train
dev=dev
test=test

# Path Variables
data_dir="data/preprocessed"
bpe_scripts="tools/subword-nmt/subword_nmt"


echo "starting data preprocessing for pipeline C..."

# Loop through experiments (10k and 20k)
for experiment in "10000 pipeline_C_10k" "20000 pipeline_C_20k"; do
    set -- $experiment
    bpe_ops=$1
    output_dir=$2

    # Derived Variables
    processed_data_dir="$output_dir/data"
    models_dir="$output_dir/models"

    # Create output directories
    # mkdir -p "$processed_data_dir" "$models_dir"

    # Morfessor (Source Only)
    echo "Training Morfessor on Finnish..."

    # 1. Train Morfessor Models (Source Only)
    morfessor-train "$data_dir/$train.tc.$src" -s "$models_dir/morfessor-model.$src"

    echo "Applying Morfessor..."

    # 2. Apply Morfessor (Source) and Copy (Target)
    for prefix in $train $dev $test; do
        # Segment Finnish
        morfessor-segment -l "$models_dir/morfessor-model.$src" \
            "$data_dir/$prefix.tc.$src" \
            -o "$processed_data_dir/$prefix.morf.$src" \
            --output-format '{analysis} ' \
            --output-format-separator " " \
            --output-newlines
        
        # Copy English so the BPE step has an input file to read (but English file is not actually morfed)
        cp "$data_dir/$prefix.tc.$tgt" "$processed_data_dir/$prefix.morf.$tgt"
    done

    echo "Morfessor done..."

    # BPE Segmentation
    bpe_code_file="$models_dir/bpe-codes.$bpe_ops"

    echo "Training BPE jointly on both languages..."
    # 1. Learn BPE (Jointly on Morf-Finnish and Clean-English)
    python3 $bpe_scripts/learn_joint_bpe_and_vocab.py \
        --input "$processed_data_dir/$train.morf.$src" "$processed_data_dir/$train.morf.$tgt" \
        -s $bpe_ops \
        -o $bpe_code_file \
        --write-vocabulary "$models_dir/vocab.$src" "$models_dir/vocab.$tgt"

    echo "Applying BPE..."
    # 2. Apply BPE Segmentation
    for prefix in $train $test $dev; do
        for lang in $src $tgt; do
            python3 $bpe_scripts/apply_bpe.py \
                -c $bpe_code_file \
                --vocabulary "$models_dir/vocab.$lang" \
                --vocabulary-threshold 50 \
                < "$processed_data_dir/$prefix.morf.$lang" \
                > "$processed_data_dir/$prefix.bpe.$lang"
        done
    done
    echo "BPE done..."
done
echo "All processes finished :))"