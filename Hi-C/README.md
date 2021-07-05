## step1: Preprocess Homer
 - 1.1: split by chr: bash PreprocessDB/Hi-C/Homer/splitChrom.sh homer_sigInteractions.txt, the split results will be in split_results folder
 - 1.2: calcualte FDR and filter by FDR<=0.05 and readcount >= 10 for all chr: perl PreprocessDB/Hi-C/Homer/run_allChr.pl
 - 1.3: merge results together: perl ~/PreprocessDB/Hi-C/Homer/merge.pl
 - 1.4: Final result: allchr.sigInteractions.HOMER

## step2: Preprocess gothic
 - 2.1: reformatting and extracting the significant Hi-C interactions (FDR <= 0.05 and readcount >= 10) from the gothic results: perl gothic2bed.pl chr*.binoCoords1 hic_resolution(ex:2,000)
 - 2.2: merge results together: perl ~/PreprocessDB/Hi-C/gothic/merge.pl
 - 2.3: Fianl result: allchr.sigInteractions.gothic

## step3: Process HiCCUPS
 - 3.1: reformatting and extracting the significant Hi-C interactions (FDR <= 0.05 and readcount >= 10) from the HiCCUPS results: perl ~/PreprocessDB/Hi-C/hiccups/hiccups2bed.pl postprocessed_pixels_*.bedpe hic_resolution(ex" 2,000)
 - 3.2: Final result: peak1_peak2_res.bed

## step4: merge Homer, gothic, HiCCUPS results:
 - 4.1: perl ~/PreprocessDB/Hi-C/merge_homer_gothic_hiccups.pl homer(step1.4) gothic(step2.3) hiccups(step3.2)
   
