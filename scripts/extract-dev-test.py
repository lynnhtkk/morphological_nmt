#!/usr/bin/env python3

import re
from pathlib import Path


def extract_text_from_sgml(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    seg_pattern = r'<seg[^>]*>([^<]*)</seg>'
    matches = re.findall(seg_pattern, content)
    
    return matches


def main():
    data_dir = Path("/Users/linnhtet/Desktop/BPC_NLP_Project/data")
    
    process_dataset(data_dir / "dev", "newstest2017*", "dev")
    process_dataset(data_dir / "test", "newstest2018*", "test")


def process_dataset(dataset_dir, file_pattern, output_prefix):
    fien_files = sorted(dataset_dir.glob(file_pattern + "-fien*"))
    
    fi_segments = []
    en_segments = []
    
    for file_path in fien_files:
        filename = file_path.name
        segments = extract_text_from_sgml(file_path)
        
        if "-src.fi" in filename:
            fi_segments.extend(segments)
        elif "-ref.en" in filename:
            en_segments.extend(segments)
    
    fi_output = dataset_dir / f"{output_prefix}.fi"
    en_output = dataset_dir / f"{output_prefix}.en"
    
    with open(fi_output, 'w', encoding='utf-8') as f:
        f.write('\n'.join(fi_segments))
    
    with open(en_output, 'w', encoding='utf-8') as f:
        f.write('\n'.join(en_segments))


if __name__ == "__main__":
    main()
