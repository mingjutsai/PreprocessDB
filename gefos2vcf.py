# include standard modules
import argparse
import os
import sys
# initiate the parser
parser = argparse.ArgumentParser()

# add long and short argument
parser.add_argument("--input", "-i", type=str, help="set output width")

# read arguments from the command line
args = parser.parse_args()

# check for --width
if args.input:
    if os.path.exists(args.input):
        gefos = args.input
        print('#gefos:' + gefos)
else:
    print('Need input file')
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