# RNA-seq Pipeline

A reproducible paired-end RNA-seq pipeline built with standard bioinformatics tools.

**Workflow:** Raw FASTQ → FastQC → Cutadapt Trimming → FastQC → STAR Alignment → samtools → featureCounts

---

## Dependencies

| Tool | Version |
|------|---------|
| STAR | 2.7.x |
| cutadapt | 4.x |
| samtools | 1.x |
| subread (featureCounts) | 2.x |
| FastQC | 0.12.x |

---

## Installation
```bash
conda env create -f environment.yml
conda activate rnaseq-pipeline
```

---

## Usage
```bash
bash pipeline.sh           # uses default 4 threads
bash pipeline.sh 8         # override with 8 threads
```

Edit `config/params.sh` to adjust trimming and alignment parameters.

---

## Input

- Paired-end FASTQ files named `*_read1.fastq.gz` / `*_read2.fastq.gz`
- Reference genome in FASTA format
- Gene annotation in GTF format

> **Note:** The download URLs in Step 2 of the script are internal to TH Deggendorf (practical session data). Replace them with your own data files.

---

## Output

| File | Description |
|------|-------------|
| `fastqc_results/` | Pre-trim QC reports |
| `fastqc_trimmed_data/` | Post-trim QC reports |
| `star_results/*.bam` | Sorted, indexed alignment files |
| `star_results/featureCounts.txt` | Raw gene count matrix |

---

## Author

**Ajaynath MK**  
M.Sc. Life Science Informatics — TH Deggendorf, Germany  
[github.com/ajaynathmk](https://github.com/ajaynathmk)
