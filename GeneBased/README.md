# GeneBased Preprocessing Tools

This directory contains a collection of Perl scripts for preprocessing gene-based databases and converting between various bioinformatics file formats.

## Main Goal
The goal of the scripts in this folder is to generate ANNOVAR format files for hg38 annotation: `hg38_ensGene.txt` and `hg38_ensGeneMrna.fa` from the latest GENCODE GTF file.

### Workflow:
1. Download the latest GENCODE GTF file for hg38 (e.g., gencode.vXX.annotation.gtf.gz from https://www.gencodegenes.org/human/).
2. Use `ensembl2UCSC_annovar.pl` to convert the GENCODE GTF to ANNOVAR format `hg38_ensGene.txt` and generate the mRNA FASTA file `hg38_ensGeneMrna.fa`.

## Scripts Overview

### 1. `ensembl2UCSC_annovar.pl`
Converts Ensembl GTF files to ANNOVAR format gene annotation files and generates corresponding mRNA FASTA files.

**Usage:**
```bash
perl ensembl2UCSC_annovar.pl --gtf <file.gtf> --build <19|38> --seqdir <reference_fasta_dir> [--outdir <output_dir>]
```

**Required arguments:**
- `--gtf, -g`: Input GTF file (e.g. Homo_sapiens.GRCh38.113.gtf)
- `--build, -b`: Genome build: 19 or 38
- `--seqdir, -s`: Directory containing reference FASTA files for the build

**Optional:**
- `--outdir, -o`: Output directory (default: same directory as the GTF)
- `--help, -h`: Show this help message

### 2. `process_genePred.pl`
Processes genePred format files, used for cleanup and normalization in the ensembl2UCSC_annovar.pl pipeline.

**Usage:**
```bash
perl process_genePred.pl convert_file input_file
```

### 3. `gene2fa.pl`
Converts gene coordinate files to FASTA format by retrieving sequences, used in the ensembl2UCSC_annovar.pl pipeline to generate mRNA FASTA.

**Usage:**
```bash
perl gene2fa.pl gene_file sequence_path db build
```

**Dependencies:** Requires `retrieve_seq_from_fasta.pl` in the same directory.

### 4. `retrieve_seq_from_fasta.pl`
Retrieves DNA sequences from FASTA files based on genomic coordinates, used by gene2fa.pl.

**Usage:**
```bash
perl retrieve_seq_from_fasta.pl [options] --regionfile regions.txt --seqdir /path/to/fasta
```

**Options:**
- `--outfile`: Output file name
- `--format`: Output format (default: fasta)
- `--seqdir`: Directory containing FASTA files
- `--seqfile`: Single FASTA file to use
- `--tabout`: Tab-delimited output
- `--altchr`: Use alternative chromosome naming
- `--addchr`: Add 'chr' prefix to chromosome names

### 5. `gencode2gene.pl`
Extracts gene information from GENCODE GTF files.

**Usage:**
```bash
perl gencode2gene.pl input.gtf
```

**Output:** Creates `input.gtf_gene.txt` with columns: Chr, Start, End, Strand, Gene_Name, Gene_ID, Gene_Type

## Data Files

- `hg19_GRCh37`: Chromosome mapping file for hg19/GRCh37 assembly

## Requirements

- Perl 5.x
- Standard Perl modules (strict, warnings, Getopt::Long, Pod::Usage, etc.)

## Notes

- All scripts should be run from this directory or with appropriate path adjustments
- Some scripts have interdependencies (e.g., gene2fa.pl requires retrieve_seq_from_fasta.pl)
- Ensure input files are in the expected formats for each script
- Check script headers for additional usage details and options