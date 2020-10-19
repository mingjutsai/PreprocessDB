import os
import argparse
import re
import gzip
def gunzip_bytes_obj(bytes_obj: bytes) -> str:
        return gzip.decompress(bytes_obj).decode()

def parse_arguments():
    parser = argparse.ArgumentParser(prog='Transfer dbSNP_vcf to Annovar format.',
                                        description='')

    # add long and short argument
    parser.add_argument('dbsnp', type=str, nargs=1,
                        help='Path for dbSNP_vcf file.')
    parser.add_argument('assembly', type=str, nargs=1,
                        help='Path for assembly_report.txt.')
    # read arguments from the command line
    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    if os.path.exists(args.dbsnp[0]):
        dbsnp = args.dbsnp[0]
        print('#dbSNP:' + dbsnp)
    else:
        raise Exception('dbSNP does not exist')
    if os.path.exists(args.assembly[0]):
        assembly = args.assembly[0]
        print('#assembly:' + assembly)
    else:
        raise Exception('assembly does not exist')
    #mapping refseq and ucsc
    file = open(assembly,'r')
    assembly_map = dict()
    for line in file:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split("\t")
        #fields[9]: UCSC-style-name
        if fields[0] in ('1','2','3','4','5','6','7','8','9','10','11'
                        ,'12','13','14','15','16','17','18','19','20'
                        ,'21','22','X','Y','MT'):
            refseq = fields[6]
            ucsc = fields[0]
            assembly_map[refseq] = ucsc
            #print('refseq:' + refseq)
            #print(assembly_map[refseq])
        else:
            continue
    file.close

    #read
    if dbsnp.endswith("gz"):
        rfile = gzip.open(dbsnp, 'rb')
    else:
        rfile = open(dbsnp,'r')
    #rfile = open(dbsnp,'r')
    output = dbsnp + '_annovar'
    wfile = open(output,'w')
    wfile.write('#Chr\tStart\tEnd\tRef\tAlt\tRSID\n')
    for line in rfile:
        if dbsnp.endswith("gz"):
            decompress_line = line.decode("utf-8")
            line = decompress_line
        #print(line)
        #print(type(line))
        #quit()
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split('\t')
        match_header = re.match('^#',fields[0])
        if match_header:
            continue
        else:
            if fields[0] in assembly_map:
                chr = assembly_map[fields[0]]
                start = int(fields[1])
                rsid = fields[2]
                ref = fields[3]
                alt = fields[4]
                end = start + len(ref) - 1
                if ',' in alt:
                    all_alt = alt.split(',')
                    for i in all_alt:
                        wfile.write(chr + '\t' + str(start) + '\t' + str(end) + '\t' + ref + '\t' + i + '\t' + rsid + '\n')
                else:
                    wfile.write(chr + '\t' + str(start) + '\t' + str(end) + '\t' + ref + '\t' + alt + '\t' + rsid + '\n')
            else:
                continue
    rfile.close
    wfile.close

    

if __name__ == '__main__':
    main()
