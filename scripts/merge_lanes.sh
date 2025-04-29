#!/usr/bin/env bash
set -euo pipefail

# If you want to override the output directory: ./merge_all_lanes.sh my_merged_dir
outdir=${1:-merged_reads}
mkdir -p "$outdir"

# 1) collect all your lane directories (they must end with "_trimmed")
lanes=( *_trimmed )
if (( ${#lanes[@]} == 0 )); then
  echo "ERROR: no directories matching '*_trimmed' found." >&2
  exit 1
fi

# 2) discover unique sample names by stripping the suffix from forward reads
mapfile -t samples < <(
  find "${lanes[@]}" -maxdepth 1 -type f -name "*_forward_paired.fastq.gz" \
    -printf "%f\n" \
  | sed 's/_forward_paired\.fastq\.gz$//' \
  | sort -u
)

if (( ${#samples[@]} == 0 )); then
  echo "ERROR: no '*_forward_paired.fastq.gz' files found in ${lanes[*]}." >&2
  exit 1
fi

# 3) loop through each sample
for sample in "${samples[@]}"; do
  echo "► Merging sample: $sample"

  # gather per-lane inputs
  fwd=()
  rev=()
  for d in "${lanes[@]}"; do
    fp="$d/${sample}_forward_paired.fastq.gz"
    rp="$d/${sample}_reverse_paired.fastq.gz"

    [[ -f $fp ]] && fwd+=( "$fp" )
    [[ -f $rp ]] && rev+=( "$rp" )
  done

  if (( ${#fwd[@]} == 0 )); then
    echo "  ⚠️  No forward reads found for $sample, skipping." >&2
    continue
  fi

  # merge forward reads
  out_fwd="$outdir/${sample}_R1.merged.fastq.gz"
  echo "  – Writing $((${#fwd[@]})) forward files → $out_fwd"
  cat "${fwd[@]}" > "$out_fwd"

  # merge reverse reads (if any)
  if (( ${#rev[@]} > 0 )); then
    out_rev="$outdir/${sample}_R2.merged.fastq.gz"
    echo "  – Writing $((${#rev[@]})) reverse files → $out_rev"
    cat "${rev[@]}" > "$out_rev"
  fi
done

echo "✅ Done. All merged files are in '$outdir/'"
