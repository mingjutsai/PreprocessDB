#!/bin/bash
# run_gothic_HiC.sh — Full GOTHiC Hi-C significant interaction pipeline
#
# Steps:
#   1. Convert .pre → per-chromosome .gothic files
#   2. Generate per-chromosome GOTHiChicup R scripts
#   3. Run GOTHiChicup R per chromosome (parallel)
#   4. gothic2bed.pl — filter FDR<=0.05, readcount>=10 per chr
#   5. merge.pl — combine all chromosomes
#
# Usage:
#   bash run_gothic_HiC.sh <sample_name> <input.pre> <outdir> <resolution> <digest_file>
# Example:
#   bash run_gothic_HiC.sh mergedOC mergedOC.bam.pre gothic_2k 2000 \
#     /mnt/Storage2/mingju/ifar/Hi-C/K562/Digest_hg38_MboI_None_14-33-48_02-09-2021.txt
#
# Requirements:
#   - R with GOTHiC + BSgenome.Hsapiens.UCSC.hg38 (Bioconductor)
#   - perl pre2gothic.pl, gothic2bed.pl, merge.pl in ~/PreprocessDB/Hi-C/gothic/

SAMPLE=$1
PRE=$2
OUTDIR=$3
RES=$4
DIGEST=$5

if [ $# -lt 5 ]; then
    echo "Usage: bash run_gothic_HiC.sh <sample> <input.pre> <outdir> <resolution> <digest_file>"
    exit 1
fi

PRE=$(realpath $PRE)
DIGEST=$(realpath $DIGEST)
PREPROCESS=$(realpath ~/PreprocessDB/Hi-C/gothic)
THREADS=18

mkdir -p $OUTDIR
cd $OUTDIR

# ── Step 1: Convert pre → per-chr gothic files ────────────────────────────
echo "[$(date)] Step 1/5 — Converting .pre to per-chr gothic files..."
perl $PREPROCESS/pre2gothic.pl $PRE $SAMPLE . 2>&1
echo "[$(date)] gothic files written: $(ls ${SAMPLE}_chr*.gothic 2>/dev/null | wc -l) chromosomes"

# ── Step 2: Generate per-chr R scripts ───────────────────────────────────
echo "[$(date)] Step 2/5 — Generating R scripts..."
for i in $(seq 1 22) X Y; do
    GOTHIC_FILE="${SAMPLE}_chr${i}.gothic"
    RESULT_FILE="${SAMPLE}_chr${i}_gothic.results"
    cat > gothic_chr${i}.r << RSCRIPT
library(GOTHiC)
binom <- GOTHiChicup("${GOTHIC_FILE}",
    sampleName    = "${SAMPLE}_chr${i}",
    restrictionFile = "${DIGEST}",
    res           = ${RES},
    cistrans      = "cis",
    parallel      = TRUE,
    cores         = 1)
write.table(binom, file = "${RESULT_FILE}", sep = "\t", row.names = FALSE)
RSCRIPT
done

# ── Step 3: Run GOTHiChicup per chromosome (parallel) ────────────────────
echo "[$(date)] Step 3/5 — Running GOTHiChicup for chr1-22, X, Y (${THREADS} parallel)..."
CHRS=$(for i in $(seq 1 22) X Y; do echo $i; done)
echo "$CHRS" | xargs -P $THREADS -I{} bash -c \
    "echo '[chr{}] Starting...' && Rscript gothic_chr{}.r > gothic_chr{}.log 2>&1 && echo '[chr{}] Done' || echo '[chr{}] FAILED'"
echo "[$(date)] All chromosomes done."

# ── Step 4: gothic2bed.pl — filter sig interactions ──────────────────────
echo "[$(date)] Step 4/5 — Filtering significant interactions (FDR<=0.05, reads>=10)..."
for i in $(seq 1 22) X Y; do
    RESULT="${SAMPLE}_chr${i}_gothic.results"
    if [ -f "$RESULT" ]; then
        perl $PREPROCESS/gothic2bed.pl $RESULT $RES
    fi
done

# ── Step 5: merge ─────────────────────────────────────────────────────────
echo "[$(date)] Step 5/5 — Merging all chromosomes..."
perl $PREPROCESS/merge.pl

echo "[$(date)] Done."
echo "Final output: $OUTDIR/allchr.sigInteractions.gothic"
