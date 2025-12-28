# Load required libraries
library(GOTHiC)
library(BSgenome.Hsapiens.UCSC.hg38)

# Run GOTHiChicup for the whole genome sample
binom_whole <- GOTHiChicup("powderOC_final.bam.gothic",
                          sampleName = "powderOC",
                          restrictionFile = "Digest_hg38.txt",
                          res = 2000,
                          cistrans = "all",
                          parallel = TRUE,
                          cores = 64)

# Run GOTHiChicup for the chromosome 1 specific sample
binom_chr1 <- GOTHiChicup("powderOC_final_mapq30.bam.chr1.gothic",
                          sampleName = "powderOC_chr1",
                          restrictionFile = "Digest_hg38.txt",
                          res = 2000,
                          cistrans = "all",
                          parallel = TRUE,
                          cores = 4)

# Write the results for the chromosome 1 analysis to file
write.table(binom_chr1, file = "powderOC_chr1_gothic.txt", sep = "\t", row.names = FALSE)