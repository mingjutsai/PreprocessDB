import argparse
import os
import re

def parse_arguments():
    ### define arguments
    str_description = ''
    str_description += 'FindDock is a batch AutoDock Vina runner for the candidate drugs or a keyword '
    str_description += 'developed by Yu-Chuan (Chester) Chang & all member of the Genomics Team at AILabs in Taiwan. '
    parser = argparse.ArgumentParser(prog='LeadSNP_gwasLocus', description=str_description)

    ### define arguments for I/O
    parser.add_argument("-l", required=True, help="the file of leadSNP")
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
        pos = fields[5]
        if pos == 'pos':
            continue
        chr = fields[4]
        rsid = fields[3]
        min_pos = int(pos) - 500000
        if min_pos < 0:
            min_pos = 0
        max_pos = int(pos) + 500000
        gwas_locus = rsid + '_locus.txt'
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
            id = re.split(':|_', gwas_id)
            gwas_chr = id[0]
            gwas_pos = int(id[1])
            if gwas_chr == chr:
                if gwas_pos > min_pos and gwas_pos < max_pos:
                    wfile.write(gwas_line)
                    #print(gwas_chr + ":" + str(gwas_pos))
        wfile.close()        
        #quit()  

            #print('gwas_chr:' + id[0])
            #print('gwas_pos:' + id[1])

if __name__ == "__main__":
    main()

