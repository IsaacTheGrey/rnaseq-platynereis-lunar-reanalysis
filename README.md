# RNA-Seq Analysis Pipeline

This pipeline automates the processing of RNA-seq data, from raw reads to counts that can be used for analysis, facilitating reproducible and efficient transcriptomic studies.

## Features

- Quality assessment with FastQC (coming soon)
- Adapter trimming using Trimmomatic
- Alignment to reference genome via STAR
- Gene quantification with featureCounts
- Transcript quantification using Salmon
- Comprehensive reporting through MultiQC (coming soon)

## Installation

```bash
git clone https://github.com/IsaacTheGrey/rnaseq-platynereis-pipeline.git
cd rnaseq-platynereis-pipeline
conda create -n rnaseq-pipeline -c bioconda -c conda-forge snakemake
conda activate rnaseq-pipeline
```
## Usage
Add the raw fastq.gz files to /data/fastq. They can also be in subdirectories. Then open a terminal in the parent folder and run:
```bash
snakemake --cores <cores> --use-conda
```

## Output
- data/star/: Aligned BAM files
- data/counts/: Gene count matrices
- results/multiqc/: Aggregated QC reports
