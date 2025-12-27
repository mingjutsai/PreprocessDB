# Hi-C Data Preprocessing Pipeline

This repository contains scripts for preprocessing Hi-C interaction data from various tools: HOMER, GOTHIC, and HiCCUPS. The pipeline filters significant interactions (FDR ≤ 0.05 and read count ≥ 10), formats them consistently, and merges results from multiple tools.

## Prerequisites

- Perl with required modules (e.g., Statistics::Multtest)
- Input files from HOMER, GOTHIC, and HiCCUPS tools

## Step 1: Preprocess HOMER Results

1.1: Split HOMER output by chromosome:  
`bash PreprocessDB/Hi-C/Homer/splitChrom.sh homer_sigInteractions.txt`  
The split results will be in the `split_results` folder.

1.2: Calculate FDR and filter by FDR ≤ 0.05 and read count ≥ 10 for all chromosomes:  
`perl PreprocessDB/Hi-C/Homer/run_allChr.pl`

1.3: Merge results together:  
`perl ~/PreprocessDB/Hi-C/Homer/merge.pl`

1.4: Final result: `allchr.sigInteractions.HOMER`

## Step 2: Preprocess GOTHIC Results

2.1: Reformat and extract significant Hi-C interactions (FDR ≤ 0.05 and read count ≥ 10) from GOTHIC results:  
`perl PreprocessDB/Hi-C/gothic/gothic2bed.pl chr*.binoCoords1 hic_resolution`  
(e.g., `perl gothic2bed.pl chr1.binoCoords1 2000`)

2.2: Merge results together:  
`perl ~/PreprocessDB/Hi-C/gothic/merge.pl`

2.3: Final result: `allchr.sigInteractions.gothic`

## Step 3: Process HiCCUPS Results

3.1: Reformat and extract significant Hi-C interactions (FDR ≤ 0.05 and read count ≥ 10) from HiCCUPS results:  
`perl ~/PreprocessDB/Hi-C/hiccups/hiccups2bed.pl postprocessed_pixels_*.bedpe hic_resolution`  
(e.g., `perl hiccups2bed.pl postprocessed_pixels_1000.bedpe 2000`)

3.2: Final result: `peak1_peak2_res.bed`

## Step 4: Merge HOMER, GOTHIC, and HiCCUPS Results

4.1: Merge the processed results from all tools:  
`perl ~/PreprocessDB/Hi-C/merge_homer_gothic_hiccups.pl homer_file gothic_file hiccups_file`  
(e.g., `perl merge_homer_gothic_hiccups.pl allchr.sigInteractions.HOMER allchr.sigInteractions.gothic peak1_peak2_res.bed`)

Output: `merge_results.txt`

## Additional Tools

- **Convert PAIRS to HOMER/GOTHIC format**: Use `pairs2homer.pl` or `pairs2gothic.pl` to convert .pairs files to input formats for HOMER or GOTHIC tools.
- **Create Enhancer-Promoter Database**: After merging, use `EP_database.pl` to generate an enhancer-promoter interaction database:  
  `perl EP_database.pl merge_results.txt`  
  Output: `merge_results.txt_EP.bed`
