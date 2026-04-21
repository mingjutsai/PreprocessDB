#!/bin/bash
# run_homer_HiC.sh — Full HOMER Hi-C significant interaction pipeline
#
# Steps:
#   1. Convert .pre file to HOMER pairs format
#   2. makeTagDirectory
#   3. analyzeHiC to call significant interactions
#   4. splitChrom.sh — split by chromosome
#   5. run_allChr.pl — filter FDR<=0.05, readcount>=10 per chr
#   6. merge.pl — combine all chromosomes
#
# Usage:
#   bash run_homer_HiC.sh <sample_name> <input.pre> <outdir> <resolution>
#   Example:
#   bash run_homer_HiC.sh mergedOC mergedOC.bam.pre homer_2k 2000
#
# Requirements:
#   - HOMER installed via pixi: pixi global install -c bioconda homer
#   - Number::FormatEng perl module: cpanm Number::FormatEng
#   - PreprocessDB/Hi-C scripts in ~/PreprocessDB/Hi-C/

SAMPLE=$1
PRE=$2
OUTDIR=$3
RES=$4

if [ $# -lt 4 ]; then
    echo "Usage: bash run_homer_HiC.sh <sample_name> <input.pre> <outdir> <resolution>"
    echo "Example: bash run_homer_HiC.sh mergedOC mergedOC.bam.pre homer_2k 2000"
    exit 1
fi

# Resolve pre file to absolute path before any cd
PRE=$(realpath $PRE)
PREPROCESS=$(realpath ~/PreprocessDB/Hi-C/Homer)
GENOME=hg38

mkdir -p $OUTDIR
cd $OUTDIR

echo "[$(date)] Step 1/6 — Converting .pre to HOMER pairs format..."
perl $PREPROCESS/pre2homer.pl $PRE ${SAMPLE}.homer
echo "[$(date)] Pairs written: $(wc -l < ${SAMPLE}.homer)"

echo "[$(date)] Step 2/6 — makeTagDirectory..."
makeTagDirectory ${SAMPLE}_tagdir \
    -format HiCsummary \
    ${SAMPLE}.homer

echo "[$(date)] Step 3/6 — analyzeHiC (res=${RES}bp, genome=${GENOME})..."
analyzeHiC ${SAMPLE}_tagdir \
    -res $RES \
    -genome $GENOME \
    -interactions ${SAMPLE}_sigInteractions.txt \
    -nomatrix

echo "[$(date)] Step 4/6 — Splitting by chromosome..."
bash $PREPROCESS/splitChrom.sh ${SAMPLE}_sigInteractions.txt

echo "[$(date)] Step 5/6 — Filtering per chromosome (FDR<=0.05, readcount>=10)..."
cd split_results
perl $PREPROCESS/run_allChr.pl

echo "[$(date)] Step 6/6 — Merging all chromosomes..."
perl $PREPROCESS/merge.pl

echo "[$(date)] Done."
echo "Final output: $OUTDIR/split_results/allchr.sigInteractions.HOMER"
