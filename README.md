# Breaking Words Better: Linguistically Guided Segmentation for Morphologically Rich Languages

Finnish-to-English Neural Machine Translation

**Team Members:** [Çağla Ece Azizoğlu](https://github.com/cagla326), [Aqil Ahmed Abdul Khaliq](https://github.com/aqat123), [Nyi Nyi Linn Htet](https://github.com/lynnhtkk)

---

## Overview

This work investigates subword segmentation methods for neural machine translation on morphologically rich languages. We compare frequency-based byte-pair encoding (BPE) with linguistically-informed morphological segmentation using Morfessor for Finnish-to-English translation.

Standard BPE operates purely on frequency statistics and often splits morphologically meaningful units. For morphologically rich languages like Finnish, where complex meanings are compressed into single words (e.g., "talossanikin" → "also in my house"), this causes data sparsity issues for rare inflections and linguistically incoherent segmentations.

Morfessor, an unsupervised morphological analyzer, produces linguistically motivated segmentations that align boundaries with morpheme boundaries and reduce sparsity by grouping semantically coherent units.

## Technical Stack

The following tools are used for data preprocessing and model training:

- **subword-nmt**: Byte-Pair Encoding (BPE) implementation for subword segmentation
- **Morfessor**: Unsupervised morphological segmentation for Finnish text
- **mosesdecoder**: Tokenization, truecasing, and detokenization utilities
- **Fairseq**: Sequence modeling toolkit for Transformer model training and inference
- **sacrebleu**: Reference-based evaluation metric for translation quality
- **COMET**: Neural-based semantic evaluation metric for translation quality

## Pipeline

### Pipeline A: Baseline (BPE-only)

```
Raw Text → Tokenization → Truecasing → BPE Encoding → Transformer → Decoding → Detokenization
```

Frequency-based subword segmentation with 10k and 20k BPE merge operations.

### Pipeline B: Morfessor (Linguistically-Informed)

```
Raw Text → Tokenization → Truecasing → Morfessor Segmentation → BPE Encoding → Transformer → Decoding → Detokenization
```

Unsupervised morphological segmentation applied to Finnish text, with BPE applied to remaining rare words. Two experiments: 10k and 20k BPE merge operations.



## Results

|  | BLEU Score |  | COMET Score |  |
|---|:---:|:---:|:---:|:---:|
| Vocabulary Size | Baseline | Morfessor | Baseline | Morfessor |
| 10k | 13.37 | **13.53** | 0.7003 | **0.7049** |
| 20k | **14.05** | 13.92 | 0.7088 | **0.7117** |

### Key Findings

Morfessor demonstrates superior semantic accuracy (COMET scores) across both vocabulary sizes, with improvements of +0.66% at 10k and +0.41% at 20k. At lower vocabulary (10k), Morfessor outperforms the baseline in both BLEU and COMET, indicating better sample efficiency with linguistically meaningful units. At higher vocabulary (20k), the baseline achieves slightly higher BLEU (+0.13%), but Morfessor maintains better semantic representation. These results suggest that morphologically-informed segmentation reduces sparsity and improves generalization, particularly beneficial for rare word forms and inflections.

## Evaluation Metrics

**BLEU (Bilingual Evaluation Understudy)** measures phrase-level similarity between system output and reference translations on a scale of 0-100. While widely used, BLEU has limitations in capturing semantic equivalence.

**COMET (Crosslingual Optimized Metric for Evaluation of Translation)** is a neural-based metric that measures semantic similarity and translation quality on a scale of 0-1. COMET correlates better with human judgment and captures semantic nuances that BLEU often misses.

## References

- [**WMT18 Shared Task Data**](https://www.statmt.org/wmt18/translation-task.html)

- [**Fairseq (Original)**](https://github.com/facebookresearch/fairseq)

- [**Fairseq (Updated Compatible Version)**](https://github.com/One-sixth/fairseq) (used in this work due to compatibility with newer dependency versions)

- [**subword-nmt (BPE Implementation)**](https://github.com/rsennrich/subword-nmt)

- [**Morfessor 2.0**](https://github.com/aalto-speech/morfessor)

- [**mosesdecoder**](https://github.com/moses-smt/mosesdecoder)