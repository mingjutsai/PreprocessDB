## step1: Preprocess Homer
 - 1.1: split by chr: bash PreprocessDB/Hi-C/Homer/splitChrom.sh homer_sigInteractions.txt, the split results will be in split_results folder
 - 1.2: calcualte FDR and filter by FDR<=0.05 and readcount >= 10 for all chr: perl PreprocessDB/Hi-C/Homer/run_allChr.pl
 - 1.3: merge results together: perl ~/PreprocessDB/Hi-C/Homer/merge.pl
 - 1.4: Final result: allchr.sigInteractions.HOMER

# step2: Preprocess gothic
 - 1.1: 
