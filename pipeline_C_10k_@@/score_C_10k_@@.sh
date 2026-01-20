#!/bin/bash

moses_scripts="tools/mosesdecoder/scripts"

input_file="pipeline_C_10k_@@/results_C_10k_@@.txt"

original_ref_file="data/test/test.en"

# temporary files
src_tok="pipeline_C_10k_@@/source.tok"
hypo_tok="pipeline_C_10k_@@/hypothesis.tok"
ref_tok="pipeline_C_10k_@@/reference.tok"

src_dtc="pipeline_C_10k_@@/source.dtc"
hypo_dtc="pipeline_C_10k_@@/hypothesis.dtc"
ref_dtc="pipeline_C_10k_@@/reference.dtc"

# output files
src_detok="pipeline_C_10k_@@/source.detok"
hypo_detok="pipeline_C_10k_@@/hypothesis.detok"
ref_detok="pipeline_C_10k_@@/reference.detok"

# extract detokenized texts
grep ^S- "$input_file" | sed 's/^S-//' | sort -n | cut -f2- > "$src_tok"
grep ^H- "$input_file" | sed 's/^H-//' | sort -n | cut -f3- > "$hypo_tok" # hypothesis (translated text)
grep ^T- "$input_file" | sed 's/^T-//' | sort -n | cut -f2- > "$ref_tok" # refernece (gold standard text)

# detruecasing
"$moses_scripts/recaser/detruecase.perl" < "$src_tok" > "$src_dtc"
"$moses_scripts/recaser/detruecase.perl" < "$hypo_tok" > "$hypo_dtc"
"$moses_scripts/recaser/detruecase.perl" < "$ref_tok" > "$ref_dtc"

# detokenizing
"$moses_scripts/tokenizer/detokenizer.perl" -l fi < "$src_dtc" > "$src_detok"
"$moses_scripts/tokenizer/detokenizer.perl" -l en < "$hypo_dtc" > "$hypo_detok"
"$moses_scripts/tokenizer/detokenizer.perl" -l en < "$ref_dtc" > "$ref_detok"

score=$(sacrebleu "$original_ref_file" -i "$hypo_detok" -m bleu -b -w 4)
# score_lc=$(sacrebleu "$original_ref_file" -i "$hypo_detok" -m bleu -b -w 4 --lowercase)

# detokenize without truecasing
# "$moses_scripts/tokenizer/detokenizer.perl" -l en < "$hypo_tok" > "$hypo_detok"
# "$moses_scripts/tokenizer/detokenizer.perl" -l en < "$ref_tok" > "$ref_detok"

# score_detok=$(sacrebleu "$original_ref_file" -i "$hypo_detok" -m bleu -b -w 4)

# cleanup
rm "$src_tok" "$hypo_tok" "$ref_tok" "$src_dtc" "$hypo_dtc" "$ref_dtc"
echo "Pipeline C (10k with \"@@ \") BLEU SCORE: $score"
# echo "Pipeline C (10k with \"@@ \") BLEU SCORE (lc): $score_lc"
# echo "Pipeline C (10k with \"@@ \") BLEU SCORE (without detruecasing): $score_detok"