#!/bin/bash
# run_analyzeHiC_parallel.sh — makeTagDirectory + per-chromosome analyzeHiC in parallel
#
# Steps:
#   1. makeTagDirectory (skipped if tag directory already exists)
#   2. analyzeHiC per chromosome in parallel (-chr), writing directly to split_results/
#   3. FDR filter per chromosome (run_allChr.pl)
#   4. Merge all chromosomes (merge.pl)
#
# Usage:
#   bash run_analyzeHiC_parallel.sh <sample_name> <homer_file> <outdir> <resolution> [max_jobs]
#   Example:
#   bash run_analyzeHiC_parallel.sh mergedOC mergedOC.homer homer_2k 2000 8
#
# Requirements:
#   - HOMER installed (makeTagDirectory, analyzeHiC in PATH)
#   - PreprocessDB/Hi-C/Homer scripts in ~/PreprocessDB/Hi-C/Homer/

SAMPLE=$1
HOMER=$2
OUTDIR=$3
RES=$4
MAX_JOBS=${5:-8}

if [ $# -lt 4 ]; then
    echo "Usage: bash run_analyzeHiC_parallel.sh <sample_name> <homer_file> <outdir> <resolution> [max_jobs]"
    echo "Example: bash run_analyzeHiC_parallel.sh mergedOC mergedOC.homer homer_2k 2000 8"
    exit 1
fi

HOMER=$(realpath $HOMER)
OUTDIR=$(realpath $OUTDIR)
TAGDIR=$OUTDIR/${SAMPLE}_tagdir
SPLITDIR=$OUTDIR/split_results
PREPROCESS=$(realpath ~/PreprocessDB/Hi-C/Homer)
LOG=$OUTDIR/analyzeHiC_parallel.log

mkdir -p $OUTDIR $SPLITDIR

# Step 1: makeTagDirectory
if [ -f "$TAGDIR/tagInfo.txt" ]; then
    echo "[$(date)] Step 1/3 — Skipping makeTagDirectory: $TAGDIR already exists" | tee -a $LOG
else
    echo "[$(date)] Step 1/3 — makeTagDirectory..." | tee -a $LOG
    makeTagDirectory $TAGDIR \
        -format HiCsummary \
        $HOMER 2>&1 | tee -a $LOG
fi

# Step 2: per-chromosome analyzeHiC
CHRS="chrY chrX chr22 chr21 chr19 chr20 chr16 chr17 chr15 chr18 chr13 chr14 chr9 chr11 chr10 chr12 chr8 chr7 chr6 chr4 chr5 chr3 chr1 chr2"

run_chr() {
    local CHR=$1
    local OUT=$SPLITDIR/${CHR}.sigInteractions.txt
    local CHRLOG=$SPLITDIR/${CHR}.analyzeHiC.log

    if [ -f "$OUT" ] && [ -s "$OUT" ]; then
        echo "[$(date)] SKIP $CHR — results already exist" >> $LOG
        return 0
    fi

    echo "[$(date)] START $CHR" >> $LOG
    analyzeHiC $TAGDIR \
        -chr $CHR \
        -res $RES \
        -interactions $OUT \
        -nomatrix \
        > $CHRLOG 2>&1
    local EXIT=$?
    if [ $EXIT -eq 0 ] && [ -s "$OUT" ]; then
        echo "[$(date)] DONE  $CHR" >> $LOG
    else
        echo "[$(date)] ERROR $CHR (exit $EXIT)" >> $LOG
    fi
}

export -f run_chr
export TAGDIR SPLITDIR RES LOG

echo "[$(date)] Step 2/3 — analyzeHiC per chromosome (max $MAX_JOBS jobs, res=${RES}bp)" >> $LOG

echo $CHRS | tr ' ' '\n' | \
    xargs -P $MAX_JOBS -I{} bash -c 'run_chr "$@"' _ {}

# Step 3: FDR filter + merge
echo "[$(date)] Step 3/3 — FDR filter + merge..." >> $LOG
cd $SPLITDIR
perl $PREPROCESS/run_allChr.pl >> $LOG 2>&1
perl $PREPROCESS/merge.pl >> $LOG 2>&1

echo "[$(date)] Done. Final output: $SPLITDIR/allchr.sigInteractions.HOMER" >> $LOG
