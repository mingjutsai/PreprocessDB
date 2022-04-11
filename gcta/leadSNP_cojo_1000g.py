#!/home/mingju/anaconda3/bin/python
import os
import re
import argparse

def parse_arguments():
    str_description = ''
    str_description += 'GCTA-COJO analysis to leadSNP from FUMA.'
    parser = argparse.ArgumentParser(prog='leadSNP_cojo', description=str_description)
    parser.add_argument('-l', required=True, help="the leadSNP file from FUMA (GenomicRiskLoci.txt)")

    return parser

def main(args=None):
    args = parse_arguments().parse_args(args)
    leadSNP = args.l
    print('leadSNP' + leadSNP)
    leadfile = open(leadSNP,"r")
    gcta = "/mnt/Storage2/mingju/ifar/tools/gcta/gcta_v1.94.0Beta_linux_kernel_4_x86_64/gcta_v1.94.0Beta_linux_kernel_4_x86_64_static"
    for line in leadfile:
        clean_line = line.rstrip('\r\n')
        ele = clean_line.split('\t')
        rsid = ele[2]
        if rsid == 'rsID':
            continue
        #elif rsid == 'rs17513135' or rsid == 'rs2793829' or rsid == 'rs79687284' or rsid == 'rs348330' or rsid == 'rs1260326' or rsid == 'rs13414381' or rsid == 'rs243024' or rsid == 'rs10184004':
        #    continue
        #chr = ele[3]
        str_cmd = gcta + " "
        str_cmd += "--bfile /mnt/Storage2/mingju/ifar/databases/1000G_EUR/1000G.EUR "
        str_cmd += "--cojo-file " + rsid + "_locus.rsid.txt " 
        str_cmd += "--cojo-cond " + rsid + "_cojo.rsid.cond "
        str_cmd += "--out " + rsid +"_locus_1000G.EUR"
        #str_cmd += "--cojo-slct "
        #str_cmd += "--cojo-p 5e-8"
        print(str_cmd)
        os.system(str_cmd)
        #quit()

if __name__ == "__main__":
    main()

