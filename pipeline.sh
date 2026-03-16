#!/bin/bash
# ============================================================
# RNA-seq Pipeline
# Author: Ajaynath MK
# Affiliation: M.Sc. Life Science Informatics, TH Deggendorf
# Description: Paired-end RNA-seq pipeline
#              QC → Trimming → STAR Alignment → featureCounts
# Dependencies: STAR 2.7.x, cutadapt 4.x, samtools 1.x,
#               subread 2.x (featureCounts), FastQC 0.12.x
# Usage: bash pipeline.sh [threads]
# ============================================================

set -euo pipefail

# Load parameters
source config/params.sh
THREADS=${1:-$THREADS}   # Override thread count from command line if provided

# Log everything
exec > >(tee pipeline.log) 2>&1
echo "[$(date)] Pipeline started"

# --- 1. Setup Directories ---
PROJECT_DIR="bio_project_auto"
mkdir -p $PROJECT_DIR/data
cd $PROJECT_DIR/data

# --- 2. Download Data ---
# NOTE: These URLs are internal to TH Deggendorf.
# Replace with your own genome.fa, annotation.gtf,
# illumina_adapter.fa, and paired FASTQ files.
echo "[$(date)] Downloading reference and sequence data..."
wget -nc https://nextcloud.th-deg.de/s/BZdNP4BQqRLae7L/download/genome.fa
wget -nc https://nextcloud.th-deg.de/s/DFEkkW8aArwFPWN/download/annotation.gtf
wget -nc https://nextcloud.th-deg.de/s/zrjyWijeAjekRr7/download/illumina_adapter.fa
wget -nc https://nextcloud.th-deg.de/s/jsbPzAmNfYRBgpk/download/seqdata.tar
tar -xvf seqdata.tar

# --- 3. QC Pre-trimming ---
echo "[$(date)] Running FastQC (pre-trim)..."
mkdir -p fastqc_results
fastqc G* -o ./fastqc_results/

# --- 4. Trimming ---
echo "[$(date)] Trimming reads..."
mkdir -p trimmed_data
for R1 in *_read1.fastq.gz; do
    R2=${R1/_read1/_read2}
    OUT1=trimmed_data/${R1/.fastq.gz/_trim.fastq.gz}
    OUT2=trimmed_data/${R2/.fastq.gz/_trim.fastq.gz}
    echo "  Trimming: $R1 + $R2"
    cutadapt \
        --cut $CUT_FRONT \
        -U $CUT_FRONT \
        -q $QUALITY_CUTOFF \
        -m $MIN_LENGTH \
        -o $OUT1 -p $OUT2 \
        $R1 $R2
done

# --- 5. QC Post-trimming ---
echo "[$(date)] Running FastQC (post-trim)..."
mkdir -p fastqc_trimmed_data
fastqc -o fastqc_trimmed_data/ trimmed_data/*fastq.gz

# --- 6. Genome Indexing ---
echo "[$(date)] Building STAR genome index..."
mkdir -p star_index
STAR --runThreadN $THREADS \
     --runMode genomeGenerate \
     --genomeDir star_index \
     --genomeFastaFiles genome.fa \
     --sjdbGTFfile annotation.gtf \
     --genomeSAindexNbases $GENOME_SA_INDEX

# --- 7. Alignment ---
echo "[$(date)] Aligning reads with STAR..."
mkdir -p star_results
for R1 in trimmed_data/*_read1_trim.fastq.gz; do
    base=$(basename $R1 _read1_trim.fastq.gz)
    echo "  Mapping: $base"
    STAR --runThreadN $THREADS \
         --genomeDir star_index \
         --readFilesIn trimmed_data/${base}_read1_trim.fastq.gz \
                       trimmed_data/${base}_read2_trim.fastq.gz \
         --readFilesCommand zcat \
         --outFileNamePrefix star_results/${base}_ \
         --outSAMtype BAM SortedByCoordinate
done

# --- 8. Index BAMs ---
echo "[$(date)] Indexing BAM files..."
cd star_results
for file in *.bam; do
    samtools index "$file"
done

# --- 9. Read Counting ---
echo "[$(date)] Running featureCounts..."
featureCounts \
    -p -s $STRANDEDNESS -g gene_id \
    -a ../annotation.gtf \
    -o featureCounts.txt \
    *.bam

echo "[$(date)] Pipeline complete!"
echo "Output: $PROJECT_DIR/data/star_results/featureCounts.txt"
