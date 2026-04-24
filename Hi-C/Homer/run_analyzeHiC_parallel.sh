#!/bin/bash
# run_analyzeHiC_parallel.sh — Run analyzeHiC per chromosome in parallel
#
# Replaces the single genome-wide analyzeHiC call in run_homer_HiC.sh with
# per-chromosome jobs run in parallel. Outputs directly to split_results/
# chrN.sigInteractions.txt, bypassing splitChrom.sh. After all chromosomes
# finish, runs run_allChr.pl and merge.pl.
#
# Usage:
#   bash run_analyzeHiC_parallel.sh <sample_name> <outdir> <resolution> [max_jobs]
#   Example:
#   bash run_analyzeHiC_parallel.sh mergedOC homer_2k 2000 8
#
# Requirements:
#   - HOMER installed (analyzeHiC in PATH)
#   - <outdir>/<sample_name>_tagdir must already exist (from makeTagDirectory)
#   - PreprocessDB/Hi-C/Homer scripts in ~/PreprocessDB/Hi-C/Homer/

SAMPLE=$1
OUTDIR=$2
RES=$3
MAX_JOBS=${4:-8}

if [ $# -lt 3 ]; then
    echo "Usage: bash run_analyzeHiC_parallel.sh <sample_name> <outdir> <resolution> [max_jobs]"
    echo "Example: bash run_analyzeHiC_parallel.sh mergedOC homer_2k 2000 8"
    exit 1
fi

OUTDIR=$(realpath $OUTDIR)
TAGDIR=$OUTDIR/${SAMPLE}_tagdir
SPLITDIR=$OUTDIR/split_results
PREPROCESS=$(realpath ~/PreprocessDB/Hi-C/Homer)
LOG=$OUTDIR/analyzeHiC_parallel.log

CHRS="chrY chrX chr22 chr21 chr19 chr20 chr16 chr17 chr15 chr18 chr13 chr14 chr9 chr11 chr10 chr12 chr8 chr7 chr6 chr4 chr5 chr3 chr1 chr2"

mkdir -p $SPLITDIR

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

echo "[$(date)] Starting per-chromosome analyzeHiC (max $MAX_JOBS jobs, res=${RES}bp)" > $LOG
echo "Tag directory: $TAGDIR" >> $LOG

echo $CHRS | tr ' ' '\n' | \
    xargs -P $MAX_JOBS -I{} bash -c 'run_chr "$@"' _ {}

echo "[$(date)] All analyzeHiC jobs done. Running FDR filter + merge..." >> $LOG

cd $SPLITDIR
perl $PREPROCESS/run_allChr.pl >> $LOG 2>&1
perl $PREPROCESS/merge.pl >> $LOG 2>&1

echo "[$(date)] Done. Final output: $SPLITDIR/allchr.sigInteractions.HOMER" >> $LOG
