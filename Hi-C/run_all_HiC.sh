#!/bin/bash
# run_all_HiC.sh — Master pipeline: HOMER + GOTHiC + HICCUPS for Hi-C data
#
# Workflow:
#   Step 1: pre2homer_gothic.pl  — read .pre ONCE, write .homer + per-chr .gothic
#   Step 2: HOMER (makeTagDirectory → analyzeHiC → filter → merge)    ─┐
#           GOTHiC (GOTHiChicup per chr → gothic2bed → merge)          ─┼─ parallel
#           HICCUPS (juicer_tools hiccups → hiccups2bed)               ─┘
#   Step 3: merge_homer_gothic_hiccups.pl → merge_results.txt
#
# Usage:
#   bash run_all_HiC.sh <sample> <input.pre> <input.hic> <resolution> <digest_file> <workdir>
# Example:
#   bash run_all_HiC.sh mergedOC mergedOC.bam.pre mergedOC.2k.hic 2000 \
#     /mnt/Storage2/mingju/ifar/Hi-C/K562/Digest_hg38_MboI_None_14-33-48_02-09-2021.txt \
#     /mnt/Storage2/mingju/ifar/Hi-C/OC/mergedOC
#
# Requirements:
#   - HOMER: pixi global install -c bioconda homer
#   - GOTHiC: R + Bioconductor GOTHiC + BSgenome.Hsapiens.UCSC.hg38
#   - cpanm Number::FormatEng
#   - juicer_tools jar (set JUICER below)

SAMPLE=$1
PRE=$2
HIC=$3
RES=$4
DIGEST=$5
WORKDIR=$6

if [ $# -lt 6 ]; then
    echo "Usage: bash run_all_HiC.sh <sample> <pre> <hic> <res> <digest> <workdir>"
    echo "Example: bash run_all_HiC.sh mergedOC mergedOC.bam.pre mergedOC.2k.hic 2000 \\"
    echo "  /path/to/Digest_hg38.txt /path/to/workdir"
    exit 1
fi

PRE=$(realpath $PRE)
HIC=$(realpath $HIC)
DIGEST=$(realpath $DIGEST)
PREPROCESS=$(realpath ~/PreprocessDB/Hi-C)
JUICER=/mnt/Storage2/mingju/ifar/Hi-C/juicer_tools_1.22.01.jar
THREADS=18

mkdir -p $WORKDIR/homer_${RES} $WORKDIR/gothic_${RES} $WORKDIR/loops
cd $WORKDIR

# ── Step 1: Single-pass conversion → .homer + per-chr .gothic ─────────────
HOMER_FILE=$WORKDIR/homer_${RES}/${SAMPLE}.homer
GOTHIC_COUNT=$(ls $WORKDIR/gothic_${RES}/${SAMPLE}_chr*.gothic 2>/dev/null | wc -l)

if [ -f "$HOMER_FILE" ] && [ "$GOTHIC_COUNT" -ge 24 ]; then
    echo "[$(date)] Step 1 — Skipping: homer + gothic files already exist"
else
    echo "[$(date)] Step 1 — Single-pass conversion: .pre → homer + gothic..."
    perl $PREPROCESS/pre2homer_gothic.pl \
        $PRE \
        $HOMER_FILE \
        $WORKDIR/gothic_${RES} \
        $SAMPLE
    echo "[$(date)] Step 1 done."
fi

# ── Step 2: HOMER, GOTHiC, HICCUPS in parallel ────────────────────────────
echo "[$(date)] Step 2 — Launching HOMER, GOTHiC, HICCUPS in parallel..."

# HOMER
(
    bash $PREPROCESS/Homer/run_analyzeHiC_parallel.sh \
        $SAMPLE \
        $HOMER_FILE \
        $WORKDIR/homer_${RES} \
        $RES \
        $THREADS
    echo "[HOMER $(date)] Done → allchr.sigInteractions.HOMER"
) > $WORKDIR/homer_${RES}/homer.log 2>&1 &
HOMER_PID=$!

# GOTHiC
(
    cd $WORKDIR/gothic_${RES}
    echo "[GOTHiC $(date)] Generating per-chr R scripts..."
    for i in $(seq 1 22) X Y; do
        cat > gothic_chr${i}.r << RSCRIPT
.libPaths(c("~/R/library", .libPaths()))
library(GOTHiC)
binom <- GOTHiChicup("${SAMPLE}_chr${i}.gothic",
    sampleName="${SAMPLE}_chr${i}",
    restrictionFile="$DIGEST",
    res=$RES, cistrans="cis", parallel=TRUE, cores=1)
write.table(binom, file="${SAMPLE}_chr${i}_gothic.results", sep="\t", row.names=FALSE)
RSCRIPT
    done
    echo "[GOTHiC $(date)] Running GOTHiChicup ($THREADS parallel chromosomes)..."
    for i in $(seq 1 22) X Y; do echo $i; done | \
        xargs -P $THREADS -I{} bash -c \
        "Rscript gothic_chr{}.r > gothic_chr{}.log 2>&1 && echo '[GOTHiC] chr{} done' || echo '[GOTHiC] chr{} FAILED'"
    echo "[GOTHiC $(date)] Filtering + merging..."
    for i in $(seq 1 22) X Y; do
        [ -f ${SAMPLE}_chr${i}_gothic.results ] && \
            perl $PREPROCESS/gothic/gothic2bed.pl ${SAMPLE}_chr${i}_gothic.results $RES
    done
    perl $PREPROCESS/gothic/merge.pl $SAMPLE $RES
    echo "[GOTHiC $(date)] Done → allchr.sigInteractions.gothic"
) > $WORKDIR/gothic_${RES}/gothic.log 2>&1 &
GOTHIC_PID=$!

# HICCUPS
(
    case $RES in
        2000) P=2; I=7; D=20000 ;;
        5000) P=4; I=7; D=20000 ;;
        *)    P=2; I=7; D=20000 ;;
    esac
    echo "[HICCUPS $(date)] Running at ${RES}bp (p=$P i=$I d=$D)..."
    java -Xmx80g -jar $JUICER hiccups \
        --cpu --threads $THREADS \
        -k KR -r $RES -f 0.1 -p $P -i $I -d $D \
        -t 0.02,1.5,1.75,2 \
        $HIC $WORKDIR/loops/
    POSTPROCESSED=$WORKDIR/loops/postprocessed_pixels_${RES}.bedpe
    if [ -f "$POSTPROCESSED" ]; then
        perl $PREPROCESS/hiccups/hiccups2bed.pl $POSTPROCESSED $RES
        echo "[HICCUPS $(date)] Done → ${POSTPROCESSED}_peak1_peak2_res.${RES}.bed"
    else
        echo "[HICCUPS $(date)] WARNING: no output produced"
    fi
) > $WORKDIR/hiccups.log 2>&1 &
HICCUPS_PID=$!

echo "  HOMER   PID $HOMER_PID   → homer_${RES}/homer.log"
echo "  GOTHiC  PID $GOTHIC_PID  → gothic_${RES}/gothic.log"
echo "  HICCUPS PID $HICCUPS_PID → hiccups.log"

wait $HOMER_PID   && echo "[$(date)] HOMER finished"   || echo "[$(date)] HOMER FAILED"
wait $GOTHIC_PID  && echo "[$(date)] GOTHiC finished"  || echo "[$(date)] GOTHiC FAILED"
wait $HICCUPS_PID && echo "[$(date)] HICCUPS finished" || echo "[$(date)] HICCUPS FAILED"

# ── Step 3: Merge all three results ───────────────────────────────────────
echo "[$(date)] Step 3 — Merging HOMER + GOTHiC + HICCUPS..."
perl $PREPROCESS/merge_homer_gothic_hiccups.pl \
    $WORKDIR/homer_${RES}/split_results/allchr.sigInteractions.HOMER \
    $WORKDIR/gothic_${RES}/allchr.sigInteractions.gothic \
    $WORKDIR/loops/postprocessed_pixels_${RES}.bedpe_peak1_peak2_res.${RES}.bed

echo "[$(date)] All done. Final output: $WORKDIR/merge_results.txt"
