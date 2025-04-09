#!/bin/bash

# Input and output directories
IN_DIR=~/projects/rnaseq-platynereis-lunar-reanalysis/data/raw
OUT_DIR=~/bioinformatics/rnaseq-platynereis-lunar-reanalysis/data/raw

mkdir -p "$OUT_DIR"

for bam in "$IN_DIR"/*.bam; do
    base=$(basename "$bam" .bam)

    echo "Processing $base"

    # Sort BAM by read name
    samtools sort -n -@ 16 -o "$OUT_DIR/${base}_sorted.bam" "$bam"

    # Convert to FASTQ (single-end in this case)
    bedtools bamtofastq \
      -i "$OUT_DIR/${base}_sorted.bam" \
      -fq "$OUT_DIR/${base}.fastq"


    # Compress the FASTQ files
    gzip "$OUT_DIR/${base}_R1.fastq"
    gzip "$OUT_DIR/${base}_R2.fastq"

    # Cleanup
    rm "$OUT_DIR/${base}_sorted.bam"
done
