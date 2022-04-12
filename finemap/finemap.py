#!/home/mingju/anaconda3/bin/python
import os
import re
import argparse

def parse_arguments():
    str_description = 'FINEMAP analysis from COJO independent signal'
    parser = argparse.ArgumentParser(prog='finemap', description=str_description)
    parser.add_argument('--cojo', required=True, help="the leadSNP file from COJO results (GenomicRiskLoci.txt.annovar.fa.cond.results.txt)")
    parser.add_argument('--gwas', required=True, help="the gwas locus folder path")
    parser.add_argument('--ld', required=True, help="the ld matrix folder path")
    parser.add_argument('--size', required=True, help="gwas sample size")

    return parser

def main(args=None):
    args = parse_arguments().parse_args(args)
    cojo = args.cojo
    gwas_locus_path = args.gwas.rstrip('\/')
    ld_path = args.ld.rstrip('\/')
    gwas_size = args.size
    print('cojo:' + cojo)
    print('locus folder:' + gwas_locus_path)
    print('ld folder:' + ld_path)
    print('gwas size:' + gwas_size)
    cojo_results = open(cojo,"r")
    for line in cojo_results:
        clean_line = line.rstrip('\r\n')
        ele = clean_line.split('\t')
        rsid = ele[2]
        if rsid == 'RSID' or rsid == 'NA':
            continue
        workdir = gwas_locus_path + "/" + rsid
        leadSNP = ele[1]
        leadSNP_ID = leadSNP.replace(':','_')
        print(leadSNP_ID)
        if not os.path.isdir(workdir):
            cmd = "mkdir " + workdir
            os.system(cmd)
        finemap_z = workdir + "/" + rsid + ".z"
        rsid_locus = gwas_locus_path + "/" + rsid + "_locus.txt"
        if not os.path.isfile(finemap_z):
            cmd = "perl /home/mingju/PreprocessDB/finemap/finemapping_input.pl " + rsid_locus + " " + finemap_z
            os.system(cmd)
        finemap_ld = workdir + "/" + rsid + ".ld"
        if not os.path.isfile(finemap_ld):
            ld_matrix = ld_path + "/" + leadSNP_ID + "_locus.txt.cut1.ld"
            if os.path.isfile(ld_matrix):
                cmd = "cp " + ld_matrix + " " + workdir + "/"
                os.system(cmd)
                cmd = "perl /home/mingju/PreprocessDB/finemap/ld2finemapping.pl " + workdir + "/" + leadSNP_ID + "_locus.txt.cut1.ld " + finemap_ld
                #print(cmd)
                #quit()
                os.system(cmd)

        master = workdir + "/master"
        if not os.path.isfile(master):
            masterfile = open(master,'w')
            masterfile.write("z;ld;snp;config;log;k;n_samples\n")
            finemap_snp = workdir + "/" + rsid + ".snp"
            finemap_config = workdir + "/" + rsid + ".config"
            finemap_log = workdir + "/" + rsid + ".log"
            finemap_k = workdir + "/" + rsid + ".k"
            if not os.path.isfile(finemap_z):
                print("finemap.z doesn't exist:" + finemap_z)
            if not os.path.isfile(finemap_ld):
                print("finemap.ld doesn't exist:" + finemap_ld)
            if os.path.isfile(finemap_z) and os.path.isfile(finemap_ld):
                masterfile.write(finemap_z + ";" + finemap_ld + ";" + finemap_snp + ";" + finemap_config + ";" + finemap_log + ";" + finemap_k + ";" + gwas_size)
        finemap = "/mnt/Storage2/mingju/ifar/tools/finemap_v1.2_x86_64/finemap_v1.2_x86_64"
        finemap_result = workdir + "/" + rsid + ".snp"
        if not os.path.isfile(finemap_result):
            if not os.path.isfile(finemap_z):
                print("finemap.z doesn't exist:" + finemap_z)
                continue
            if not os.path.isfile(finemap_ld):
                print("finemap.ld doesn't exist:" + finemap_ld)
                continue
            cmd = finemap + " --sss --in-files " + master
            print(cmd)
            os.system(cmd)


if __name__ == "__main__":
    main()

