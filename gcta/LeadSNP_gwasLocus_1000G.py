#!/home/mingju/anaconda3/bin/python
import argparse
import os
import re

def parse_arguments():
    ### define arguments
    str_description = ''
    str_description += 'Split GWAS summary to locus. '
    str_description += 'generate gcta format from leadSNP locus '
    parser = argparse.ArgumentParser(prog='LeadSNP_gwasLocus', description=str_description)

    ### define arguments for I/O
    parser.add_argument("-l", required=True, help="the file of leadSNP (from FUMA: GenomicRiskLoci.txt)")
    parser.add_argument("-i", required=True, help="the file of gwas_summary")
    
    return parser

def main(args=None):
    ### obtain arguments from argument parser
    args = parse_arguments().parse_args(args)    
    leadSNP = ""
    leadSNP = args.l
    summary = ""
    summary = args.i
    print('leadSNP:' + leadSNP)
    print('summary:' + summary)

    leadfile = open(leadSNP,"r")
    for line in leadfile:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split("\t")
        pos = fields[4]
        if pos == 'pos':
            continue
        chr = fields[3]
        rsid = fields[2]
        min_pos = int(pos) - 500000
        if min_pos < 0:
            min_pos = 0
        max_pos = int(pos) + 500000
        gwas_locus = rsid + '_locus.rsid.txt'
        print('leadSNP:' + rsid)
        wfile = open(gwas_locus,'w')
        wfile.write('SNP\tA1\tA2\tEAF\tBeta\tSE\tP\tN\n')
        gwasfile = open(summary,"r")
        for gwas_line in gwasfile:
            clean_gwas_line = gwas_line.rstrip('\r\n')
            gwas_fields = clean_gwas_line.split('\t')
            gwas_id = gwas_fields[0]
            if gwas_id == 'SNP':
                continue
            gwas_chr = gwas_fields[1]
            gwas_pos = int(gwas_fields[2])
            gwas_a1 = gwas_fields[3]
            gwas_a2 = gwas_fields[4]
            eaf = gwas_fields[6]
            beta =  gwas_fields[7]
            se =  gwas_fields[8]
            p =  gwas_fields[9]
            n =  gwas_fields[10]
            if gwas_chr == chr:
                if gwas_pos > min_pos and gwas_pos < max_pos:
                    wfile.write(gwas_id + "\t" + gwas_a1 + "\t" + gwas_a2 + "\t" + eaf + "\t" + beta + "\t" + se + "\t" + p + "\t" + n + "\n")
                    #print(gwas_chr + ":" + str(gwas_pos))
        wfile.close()        
        #quit()  

            #print('gwas_chr:' + id[0])
            #print('gwas_pos:' + id[1])

if __name__ == "__main__":
    main()

