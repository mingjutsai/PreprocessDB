# Hi-C Significant Interaction Pipeline

Identifies significant Hi-C chromatin interactions from juicer `.pre` files using three complementary methods (HOMER, GOTHiC, HiCCUPS), then merges the results into a unified interaction database.

**Filters applied:** FDR ≤ 0.05, read count ≥ 10, MAPQ ≥ 30, cis-only interactions.

---

## Repository Structure

```
Hi-C/
├── run_all_HiC.sh              # Master script — runs everything in one command
├── pre2homer_gothic.pl         # Single-pass .pre → HOMER + GOTHiC conversion
├── merge_homer_gothic_hiccups.pl  # Merges results from all three tools
├── EP_database.pl              # Generates enhancer-promoter interaction database
├── Homer/
│   ├── run_analyzeHiC_parallel.sh  # makeTagDirectory + per-chr analyzeHiC (parallel)
│   ├── splitChrom.sh               # Split interactions by chromosome
│   ├── run_allChr.pl               # Filter per chromosome (18 parallel jobs)
│   ├── homer2bed_simple.pl         # Filter FDR<=0.05, reads>=10
│   └── merge.pl                    # Merge all chromosomes
├── gothic/
│   ├── run_gothic_HiC.sh       # Full GOTHiC pipeline
│   ├── gothic2bed.pl           # Filter FDR<=0.05, reads>=10
│   └── merge.pl                # Merge all chromosomes
└── hiccups/
    ├── run_hiccups_HiC.sh      # Full HiCCUPS pipeline
    └── hiccups2bed.pl          # Filter FDR<=0.05, reads>=10
```

---

## Prerequisites

### Software
- **HOMER**: `pixi global install -c bioconda -c conda-forge homer`
- **GOTHiC** (R/Bioconductor):
  ```r
  BiocManager::install(c("GOTHiC", "BSgenome.Hsapiens.UCSC.hg38"))
  ```
- **juicer_tools** jar (for HiCCUPS)
- **Perl modules**: `cpanm Number::FormatEng`

### Input files
| File | Description |
|------|-------------|
| `<sample>.bam.pre` | Juicer-format read pairs (11-col, sorted by chr) |
| `<sample>.hic` | Generated from `.pre` with `juicer_tools pre -r <res> -k KR` |
| `Digest_hg38_*.txt` | MboI restriction digest file for GOTHiC |

#### What is a `.pre` file?

A `.pre` file is the intermediate text format produced by the juicer alignment pipeline. It stores every aligned read pair at base-pair resolution — one pair per line, 11 tab-separated columns:

```
readname  str1 chr1 pos1 frag1  str2 chr2 pos2 frag2  mapq1 mapq2
```

| Column | Description |
|--------|-------------|
| readname | Read pair ID |
| str1 / str2 | Strand of each read (0 = forward, 16 = reverse) |
| chr1 / chr2 | Chromosome of each read |
| pos1 / pos2 | Genomic position of each read (bp) |
| frag1 / frag2 | Restriction fragment index |
| mapq1 / mapq2 | Mapping quality of each read |

Because it stores every read pair as plain text, `.pre` files are large (100+ GB for deep datasets). The `.hic` file is the compressed, binned, indexed form of the same data — smaller and faster to query, but requires the `.pre` to regenerate at a different resolution.

> **Note:** The `.hic` file must have KR normalization at the target resolution.  
> Generate with: `java -Xmx80g -jar juicer_tools.jar pre -r 2000 -q 30 -k KR -v --threads 18 input.pre output.hic hg38`

---

## Quick Start — Run All Three Methods

```bash
bash ~/PreprocessDB/Hi-C/run_all_HiC.sh \
    <sample_name> \
    <input.pre> \
    <input.hic> \
    <resolution> \
    <digest_file> \
    <workdir>
```

**Example (mergedOC at 2kb):**
```bash
bash ~/PreprocessDB/Hi-C/run_all_HiC.sh \
    mergedOC \
    mergedOC.bam.pre \
    mergedOC.2k.hic \
    2000 \
    /mnt/Storage2/mingju/ifar/Hi-C/K562/Digest_hg38_MboI_None_14-33-48_02-09-2021.txt \
    /mnt/Storage2/mingju/ifar/Hi-C/OC/mergedOC
```

**Outputs:**
```
workdir/
├── homer_2000/split_results/allchr.sigInteractions.HOMER
├── gothic_2000/allchr.sigInteractions.gothic
├── loops/postprocessed_pixels_2000.bedpe_peak1_peak2_res.2000.bed
└── merge_results.txt   ← final unified significant interactions
```

---

## Workflow Overview

```
input.pre (juicer format)
      │
      ▼
pre2homer_gothic.pl          ← reads .pre ONCE, outputs both formats
      ├── sample.homer        (HOMER pairs: id chr1 pos1 strand1 chr2 pos2 strand2)
      └── gothic/sample_chr{1..22,X,Y}.gothic  (GOTHiC per-chr format)
      
      ┌──────────────────────┬──────────────────────┬─────────────────┐
      ▼                      ▼                      ▼
   HOMER                  GOTHiC                HICCUPS
makeTagDirectory      GOTHiChicup R          juicer_tools hiccups
analyzeHiC            (per chr, parallel)    (KR normalized .hic)
splitChrom            gothic2bed.pl          hiccups2bed.pl
run_allChr.pl         merge.pl
merge.pl
      │                      │                      │
      ▼                      ▼                      ▼
allchr.sigInteractions  allchr.sigInteractions  peak1_peak2_res.bed
      .HOMER                .gothic
      │                      │                      │
      └──────────────────────┴──────────────────────┘
                             │
                             ▼
              merge_homer_gothic_hiccups.pl
                             │
                             ▼
                     merge_results.txt
                             │
                             ▼
                      EP_database.pl
                             │
                             ▼
                  merge_results.txt_EP.bed
             (enhancer-promoter interactions)
```

---

## Step-by-Step (Manual)

### Step 1 — Convert .pre to HOMER + GOTHiC formats

Reads the `.pre` file **once** and writes both output formats simultaneously:

```bash
perl ~/PreprocessDB/Hi-C/pre2homer_gothic.pl \
    input.pre \
    sample.homer \
    gothic/ \
    sample
```

### Step 2A — HOMER

```bash
bash ~/PreprocessDB/Hi-C/Homer/run_analyzeHiC_parallel.sh \
    <sample> <homer_file> <outdir> <resolution> [max_jobs]
```

Internally runs:
1. `makeTagDirectory` — index pairs into HOMER tag directory (skipped if already exists)
2. `analyzeHiC` — per-chromosome in parallel, call interactions with Z-score, LogP, FDR
3. `run_allChr.pl` — filter FDR ≤ 0.05, reads ≥ 10 (18 parallel chr jobs)
4. `merge.pl` → `allchr.sigInteractions.HOMER`

### Step 2B — GOTHiC

```bash
bash ~/PreprocessDB/Hi-C/gothic/run_gothic_HiC.sh \
    <sample> <input.pre> <outdir> <resolution> <digest_file>
```

Internally runs:
1. Per-chr GOTHiChicup R scripts (18 chromosomes in parallel)
2. `gothic2bed.pl` — filter FDR ≤ 0.05, reads ≥ 10
3. `merge.pl` → `allchr.sigInteractions.gothic`

### Step 2C — HiCCUPS

```bash
bash ~/PreprocessDB/Hi-C/hiccups/run_hiccups_HiC.sh \
    <input.hic> <outdir> <resolution>
```

Internally runs:
1. `juicer_tools hiccups` — loop calling with KR normalization
2. `hiccups2bed.pl` — filter FDR ≤ 0.05, reads ≥ 10

> **HiCCUPS resolution parameters:**
> | Resolution | `-p` | `-i` |
> |-----------|------|------|
> | 2000 bp   | 2    | 7    |
> | 5000 bp   | 4    | 7    |

### Step 3 — Merge All Results

```bash
perl ~/PreprocessDB/Hi-C/merge_homer_gothic_hiccups.pl \
    allchr.sigInteractions.HOMER \
    allchr.sigInteractions.gothic \
    peak1_peak2_res.2000.bed
```

Output: `merge_results.txt` — each interaction annotated with which tool(s) identified it.

### Step 4 — Enhancer-Promoter Database

```bash
perl ~/PreprocessDB/Hi-C/EP_database.pl merge_results.txt
```

Output: `merge_results.txt_EP.bed`
