#!/bin/bash

# !! Should be run from the root directory (BPC_NLP_PROJECT) !!

src=fi
tgt=en

# Path variables
data_dir="data/preprocessed"
model_dir="models-common"
moses_scripts="tools/mosesdecoder/scripts"
bpe_scripts="tools/subword-nmt/subword_nmt"

max_len=100

# TRAIN

prefix="train"

# 1. tokenize
for lang in $src $tgt; do
    cat "data/train/$prefix.$lang" | \
    $moses_scripts/tokenizer/normalize-punctuation.perl -l $lang | \
    $moses_scripts/tokenizer/tokenizer.perl -a -l $lang \
    > "$data_dir/$prefix.tok.$lang"
done

# 2. clean corpus
$moses_scripts/training/clean-corpus-n.perl \
    "$data_dir/$prefix.tok" \
    $src $tgt \
    "$data_dir/$prefix.clean" \
    1 $max_len

# 3. train truecaser
for lang in $src $tgt; do
    $moses_scripts/recaser/train-truecaser.perl \
        --model "$model_dir/truecase-model.$lang" \
        --corpus "$data_dir/$prefix.tok.$lang"
done

# 4. apply truecasing
for lang in $src $tgt; do
    $moses_scripts/recaser/truecase.perl \
        --model "$model_dir/truecase-model.$lang" \
        < "$data_dir/$prefix.clean.$lang" \
        > "$data_dir/$prefix.tc.$lang"
done

# 5. remove intermediate files
rm "$data_dir/$prefix.tok.$src" "$data_dir/$prefix.tok.$tgt"
rm "$data_dir/$prefix.clean.$src" "$data_dir/$prefix.clean.$tgt"


# DEV & TEST

# 1. tokenize
for split in dev test; do
    for lang in $src $tgt; do
        cat "data/$split/$split.$lang" | \
        $moses_scripts/tokenizer/normalize-punctuation.perl -l $lang | \
        $moses_scripts/tokenizer/tokenizer.perl -a -l $lang \
        > "$data_dir/$split.tok.$lang"
    done
done

# 2. apply truecasing
for split in dev test; do
    for lang in $src $tgt; do
        $moses_scripts/recaser/truecase.perl \
            --model "$model_dir/truecase-model.$lang" \
            < "$data_dir/$split.tok.$lang" \
            > "$data_dir/$split.tc.$lang"
    done
done

# 3. remove intermediate files
rm "$data_dir"/dev.tok.* "$data_dir"/test.tok.*
