#!/bin/bash
start_all=$(date +%s)

IN_DIR=~/projects/rnaseq-platynereis-lunar-reanalysis/data/raw
OUT_DIR=~/projects/rnaseq-platynereis-lunar-reanalysis/data/fastq

mkdir -p "$OUT_DIR"

export OUT_DIR  # Make available inside GNU parallel jobs

process_bam () {
    bam=$1
    base=$(basename "$bam" .bam)
    fq="$OUT_DIR/${base}.fastq"

    echo "[$base] Starting at $(date)"
    start_time=$(date +%s)

    # Run Picard with up to 64 GB RAM
    picard -Xmx64G SamToFastq \
        I="$bam" \
        FASTQ="$fq" \
        VALIDATION_STRINGENCY=SILENT \
        QUIET=true

    # Compress if successful
    if [[ -s "$fq" ]]; then
        gzip "$fq"
        end_time=$(date +%s)
        runtime=$((end_time - start_time))
        echo "✅ [$base] Completed in ${runtime}s"
    else
        echo "❌ [$base] Failed: FASTQ not created"
    fi
}

export -f process_bam

# Run 8 in parallel — change to match your CPU count
find "$IN_DIR" -name "*.bam" | parallel -j 8 process_bam
end_all=$(date +%s)
echo "🕒 Total time: $((end_all - start_all)) seconds"
