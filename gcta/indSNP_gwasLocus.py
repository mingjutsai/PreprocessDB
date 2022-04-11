#!/home/mingju/anaconda3/bin/python
import argparse
import os
import re

def parse_arguments():
    ### define arguments
    str_description = ''
    str_description += 'extract SNPs around oond-lead-snp. '
    parser = argparse.ArgumentParser(prog='LeadSNP_gwasLocus', description=str_description)

    ### define arguments for I/O
    parser.add_argument("-l", required=True, help="the file of cond-leadSNP (GenomicRiskLoci.txt.annovar.fa.cond.results.txt)")
    parser.add_argument("-i", required=True, help="the file of gwas_summary with .gcta format")
    parser.add_argument("-o", required=True, help="the output path")
    
    return parser

def main(args=None):
    ### obtain arguments from argument parser
    args = parse_arguments().parse_args(args)    
    leadSNP = ""
    leadSNP = args.l
    summary = ""
    summary = args.i
    o_path = args.o
    print('leadSNP:' + leadSNP)
    print('summary:' + summary)
    print('output path:' + o_path)

    leadfile = open(leadSNP,"r")
    for line in leadfile:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split("\t")
        leadSNP = fields[1]
        if leadSNP == 'LeadSNP':
            continue
        snp = re.split(':|_', leadSNP)
        snp_chr = snp[0]
        snp_pos = snp[1]
        snp_ref = snp[2]
        snp_alt = snp[3]
        filename = snp_chr + "_" + snp_pos + "_" + snp_ref + "_" + snp_alt
        leadID = snp_chr + ':' + snp_pos + '_' + snp_ref + '_' + snp_alt
        min_pos = int(snp_pos) - 500000
        if min_pos < 0:
            min_pos = 0
        max_pos = int(snp_pos) + 500000
        gwas_locus = o_path + "/" + filename + '_locus.txt'
        print('leadSNP:' + leadSNP)
        wfile = open(gwas_locus,'w')
        wfile.write('SNP\tLeadSNP\n')
        gwasfile = open(summary,"r")
        for gwas_line in gwasfile:
            clean_gwas_line = gwas_line.rstrip('\r\n')
            gwas_fields = clean_gwas_line.split('\t')
            gwas_id = gwas_fields[0]
            if gwas_id == 'SNP':
                continue
            id = re.split(':|_', gwas_id)
            gwas_chr = id[0]
            gwas_pos = int(id[1])
            if gwas_chr == snp_chr:
                if gwas_pos > min_pos and gwas_pos < max_pos:
                    wfile.write(gwas_id + "\t" + leadID + "\n")
                    #print(gwas_chr + ":" + str(gwas_pos))
        wfile.close()        
        #quit()  

            #print('gwas_chr:' + id[0])
            #print('gwas_pos:' + id[1])

if __name__ == "__main__":
    main()

