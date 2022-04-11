#!/home/mingju/anaconda3/bin/python
import argparse
import os
import re


def parse_arguments():
    str_description = 'get conditional independent signal from GCTA-COJO results (.cma)'
    parser = argparse.ArgumentParser(prog='get_cond_singnal', description=str_description)
    parser.add_argument('-l', required=True, help="the leadSNP from FUMA (GenomicRiskLoci.txt)")

    return parser

def main(args=None):
    args = parse_arguments().parse_args(args)
    leadSNP = args.l
    cutoff = 0.00000005
    print('leadSNP:' + leadSNP)
    cond_results = leadSNP + '.cond.results.txt'
    wfile = open(cond_results,'w')
    wfile.write('Locus No\tLeadSNP\tRSID\tP\tpC\n')
    sort_cma_app = "/home/mingju/PreprocessDB/gcta/sort_cojo_cma.py"
    if os.path.exists(sort_cma_app):
        print('sort app:' + sort_cma_app)
    else:
        print('sort app doesn not exist')
        quit()
    leadfile = open(leadSNP,"r")
    #locus_no = 1
    for line in leadfile:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split('\t')
        rsid = fields[2]
        if rsid == 'rsID':
            continue
        locus_no = fields[0]
        print('locus:' + str(locus_no))
        pvalue = fields[5]
        id = fields[1]
        wfile.write(locus_no + "\t" + id + "\t" + rsid + "\t" + pvalue + "\tNA\n")
        cma = rsid + "_locus_1000G.EUR.cma.cojo"
        if os.path.exists(cma):
            print('cma:' + cma)
        else:
            print('cma (' + cma + ') does not exist')
            continue
        cmd = "python " + sort_cma_app + " -c " + cma
        print(cmd)
        os.system(cmd)
        cma_sort = cma + ".sort.tsv"
        sortfile = open(cma_sort,"r")
        for cma_line in sortfile:
            clean_cma_line = cma_line.rstrip('\r\n')
            cma_ele = clean_cma_line.split('\t')
            cma_snp = cma_ele[1]
            if cma_snp == 'SNP':
                continue
            cma_p = cma_ele[7]
            cma_pc = cma_ele[12]
            cma_pc_value = float(cma_pc)
            print('cma_pc:' + cma_pc)
            print('cma_pc_value:' + str(cma_pc_value))
            if cma_pc_value < cutoff:
                wfile.write(str(locus_no) + "\t" + cma_snp + "\tNA" + "\t" + cma_p + "\t" + cma_pc + "\n")
                quit
            else:
                break



if __name__ == "__main__":
    main()
