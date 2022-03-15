#!/home/mingju/anaconda3/bin/python
import argparse
import os
import re
import pandas as pd


def parse_arguments():
    ### define arguments
    str_description = ''
    str_description += 'sort cojo.cma '
    parser = argparse.ArgumentParser(prog='sort_cojo_cma', description=str_description)

    ### define arguments for I/O
    parser.add_argument("-c", required=True, help="cojo.cma")
    
    return parser

def main(args=None):
    ### obtain arguments from argument parser
    args = parse_arguments().parse_args(args)    
    cma = args.c
    print('cma:' + cma)
    cma_df = pd.read_csv(cma, sep="\t")
    cma_sort = cma_df.sort_values(
        by="pC"        
    )
    cma_sort_tsv = cma + ".sort.tsv"
    cma_sort.to_csv(cma_sort_tsv, sep="\t", index=False)
    #cma_sort_file = open(cma_sort_tsv,"w")
    #cam_sort_file.write
    #print(cma_sort.head())

if __name__ == "__main__":
    main()

