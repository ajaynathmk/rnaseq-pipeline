# ============================================================
# RNA-seq Pipeline Parameters
# Edit these values before running the pipeline
# ============================================================

THREADS=4               # Number of CPU threads
MIN_LENGTH=25           # Minimum read length after trimming
QUALITY_CUTOFF=30       # Phred quality score cutoff
CUT_FRONT=10            # Bases to cut from 5' end
STRANDEDNESS=2          # featureCounts: 0=unstranded, 1=forward, 2=reverse
GENOME_SA_INDEX=11      # STAR: set 11 for small genomes, 14 for full human
