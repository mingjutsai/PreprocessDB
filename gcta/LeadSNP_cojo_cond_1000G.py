#!/home/mingju/anaconda3/bin/python
import argparse
import os
import re

def parse_arguments():
    ### define arguments
    str_description = ''
    str_description += 'Generate GCTA-COJO conditional SNP file '
    parser = argparse.ArgumentParser(prog='LeadSNP_gwasLocus', description=str_description)

    ### define arguments for I/O
    parser.add_argument("-l", required=True, help="GenomicRiskLoci.txt from FUMA")
    
    return parser

def main(args=None):
    ### obtain arguments from argument parser
    args = parse_arguments().parse_args(args)    
    leadSNP = ""
    leadSNP = args.l
    print('leadSNP:' + leadSNP)

    leadfile = open(leadSNP,"r")
    for line in leadfile:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split("\t")
        rsid = fields[2]
        if chr == 'rsID':
            continue
        print('leadSNP:' + rsid)
        cojo_cond = rsid + "_cojo.rsid.cond"
        wfile = open(cojo_cond,'w')
        wfile.write(rsid + '\n')
        wfile.close()        
        #quit()  

            #print('gwas_chr:' + id[0])
            #print('gwas_pos:' + id[1])

if __name__ == "__main__":
    main()

