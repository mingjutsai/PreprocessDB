# dbSNP Data Preprocessing

This repository provides tools and documentation for preprocessing dbSNP (Single Nucleotide Polymorphism database) data for downstream genomic analysis.

## Overview

dbSNP is a comprehensive database maintained by NCBI that catalogs genetic variations, including SNPs, insertions, deletions, and other polymorphisms. Preprocessing dbSNP data involves downloading, filtering, annotating, and formatting the data to prepare it for specific research needs.


## Preprocessing Steps

### 1. Download dbSNP Data

Download the latest dbSNP VCF files from NCBI:

```bash
wget https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.40.gz
```


### 2. Format Conversion

Convert to formats suitable for Annotation.

## Scripts

- `dbSNP2Annovar_splitChrom.pl`: Perl script to convert dbSNP VCF files to ANNOVAR format, split by chromosome.

## Converting dbSNP to ANNOVAR Format

The `dbSNP2Annovar_splitChrom.pl` script processes dbSNP VCF.gz files into ANNOVAR-compatible format.

### Prerequisites

- Perl
- gunzip (for handling compressed VCF files)

### Download Sequence Report

Download the genome assembly report from NCBI Datasets:
```bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_assembly_report.txt
```

### Usage

Provide the VCF.gz file and the sequence report as arguments:

```bash
perl dbSNP2Annovar_splitChrom.pl <vcf.gz> <sequence_report.tsv>
```

This generates output files such as `<vcf.gz>_Chr1_annovar`, `<vcf.gz>_Chr2_annovar`, etc., in ANNOVAR format with columns: Chr, Start, End, Ref, Alt, RSID, AF.


## Contributing

Please submit issues or pull requests for improvements.

## License

MIT License
