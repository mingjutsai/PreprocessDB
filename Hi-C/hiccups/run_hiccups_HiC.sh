#!/bin/bash
# run_hiccups_HiC.sh — Run HICCUPS loop calling + post-process to BED
#
# Steps:
#   1. Run juicer_tools hiccups on .hic file
#   2. hiccups2bed.pl — filter FDR<=0.05, readcount>=10
#
# Usage:
#   bash run_hiccups_HiC.sh <input.hic> <outdir> <resolution>
# Example:
#   bash run_hiccups_HiC.sh mergedOC.2k.hic loops 2000
#
# Requirements:
#   - juicer_tools jar (set JUICER below)
#   - .hic must have KR normalization at the requested resolution
#     (generated with: juicer_tools pre -r <resolution> -k KR ...)

JUICER=/mnt/Storage2/mingju/ifar/Hi-C/juicer_tools_1.22.01.jar
PREPROCESS=~/PreprocessDB/Hi-C/hiccups

HIC=$1
OUTDIR=$2
RES=$3

if [ $# -lt 3 ]; then
    echo "Usage: bash run_hiccups_HiC.sh <input.hic> <outdir> <resolution>"
    echo "Example: bash run_hiccups_HiC.sh mergedOC.2k.hic loops 2000"
    exit 1
fi

HIC=$(realpath $HIC)
mkdir -p $OUTDIR

# Resolution-specific HICCUPS parameters
# -p peak window (pixels), -i inner distance (pixels)
case $RES in
    2000)  P=2; I=5  ;;
    5000)  P=4; I=7  ;;
    10000) P=2; I=5  ;;
    25000) P=1; I=3  ;;
    *)     P=2; I=5  ;;
esac

echo "[$(date)] Step 1/2 — Running HICCUPS at ${RES}bp..."
java -Xmx80g -jar $JUICER hiccups \
    -k KR \
    -r $RES \
    -f 0.1 \
    -p $P \
    -i $I \
    -t 0.02,1.5,1.75,2 \
    --threads 18 \
    $HIC \
    $OUTDIR

echo "[$(date)] Step 2/2 — Post-processing with hiccups2bed.pl..."
POSTPROCESSED=$OUTDIR/postprocessed_pixels_${RES}.bedpe
if [ -f "$POSTPROCESSED" ]; then
    perl $PREPROCESS/hiccups2bed.pl $POSTPROCESSED $RES
    echo "[$(date)] Done."
    echo "Final output: ${POSTPROCESSED}_peak1_peak2_res.${RES}.bed"
else
    echo "WARNING: $POSTPROCESSED not found — HICCUPS may have failed."
    exit 1
fi
