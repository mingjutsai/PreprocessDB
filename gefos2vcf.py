import argparse
import os
# initiate the parser
def parse_arguments():
    parser = argparse.ArgumentParser(prog='Transfer Gefos data to vcf format.',
                                        description='')

    # add long and short argument
    parser.add_argument('input', type=str, nargs=1,
                        help='Path for Gefos file.')
    
    # read arguments from the command line
    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    if os.path.exists(args.input[0]):
        gefos = args.input[0]
        print('#gefos:' + gefos)
    else:
        raise Exception('input file does not exist')
    print('#CHROM\tPOS\tID\tREF\tALT\tFILTER\tINFO\tFORMAT\tGEFOS')
    file = open(gefos,"r")
    for line in file:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split("\t")
        rsid = fields[1]
        if rsid == 'RSID':
            continue
        chr = fields[2]
        pos = fields[3]
        ref = fields[4]
        alt = fields[5]
        filter = '.'
        info = fields[6] + ',' + fields[7] + ',' + fields[8] + ',' + fields[9] \
         + ',' + fields[10] + ',' + fields[11] + ',' + fields[12] + ',' + fields[13] 
        print(chr + '\t' + pos + '\t' + rsid + '\t' + ref + '\t' + alt + '\t' + filter + '\t' + info + '\tNA\tNA')
    file.close()

if __name__ == "__main__":
    main()