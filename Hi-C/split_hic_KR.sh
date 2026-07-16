#!/usr/bin/env bash
# Dump intrachromosomal KR-normalized contact matrices from a .hic file.

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: split_hic_KR.sh <input.hic> <output_dir> <resolution> [jobs] [straw]

Example:
  split_hic_KR.sh sample.3k.hic 3k 3000 8

Environment:
  CHROM_PREFIX  Chromosome prefix used inside the .hic file (default: chr).
                Set to an empty string for chromosome names such as 1 and X.
EOF
}

if [ "$#" -lt 3 ] || [ "$#" -gt 5 ]; then
    usage >&2
    exit 1
fi

HIC=$1
OUTDIR=$2
RES=$3
JOBS=${4:-4}
STRAW=${5:-}
CHROM_PREFIX=${CHROM_PREFIX-chr}

if [ ! -f "$HIC" ]; then
    echo "ERROR: input .hic file not found: $HIC" >&2
    exit 1
fi
if ! [[ "$RES" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: resolution must be a positive integer: $RES" >&2
    exit 1
fi
if ! [[ "$JOBS" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: jobs must be a positive integer: $JOBS" >&2
    exit 1
fi

if [ -z "$STRAW" ]; then
    if command -v straw >/dev/null 2>&1; then
        STRAW=$(command -v straw)
    else
        STRAW=$HOME/PreprocessDB/Hi-C/straw/build/straw
    fi
fi
if [ ! -x "$STRAW" ]; then
    echo "ERROR: Straw executable not found or not executable: $STRAW" >&2
    exit 1
fi

HIC=$(realpath "$HIC")
mkdir -p "$OUTDIR"
OUTDIR=$(realpath "$OUTDIR")
PREFIX=$(basename "$HIC")
CHROMS=({1..22} X Y)

dump_chromosome() {
    local chrom=$1
    local query_chrom="${CHROM_PREFIX}${chrom}"
    local output_chrom="chr${chrom}"
    local output="$OUTDIR/$PREFIX.KR.$output_chrom"
    local temporary="$output.tmp.$$"

    echo "[$(date)] Starting $query_chrom -> $output"
    if "$STRAW" observed KR "$HIC" "$query_chrom" "$query_chrom" BP "$RES" > "$temporary"; then
        mv "$temporary" "$output"
        echo "[$(date)] Finished $query_chrom"
    else
        rm -f "$temporary"
        echo "[$(date)] ERROR: failed to dump $query_chrom" >&2
        return 1
    fi
}

export HIC OUTDIR RES STRAW CHROM_PREFIX PREFIX
export -f dump_chromosome

printf '%s\n' "${CHROMS[@]}" | xargs -P "$JOBS" -n 1 bash -c 'dump_chromosome "$1"' _

echo "[$(date)] Done. Outputs: $OUTDIR/$PREFIX.KR.chr*"
