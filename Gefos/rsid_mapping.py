import argparse
import os
import re
#from subprocess import PIPE, run
def parse_arguments():
    parser = argparse.ArgumentParser(prog='Assembly transfer.',
                                        description='Using rsid to transfer hg38 <-> hg19')

    # add long and short argument
    parser.add_argument('vcf', type=str, nargs=1,
                        help='Path for vcf file.')
    parser.add_argument('dbSNP', type=str, nargs=1,
                        help='Path for dbSNP file <annovar format>')
    parser.add_argument('--hg19To38', action="store_true", help='Process hg19To38')
    parser.add_argument('--hg38To19', action="store_true", help='Process hg38To19')
    # read arguments from the command line
    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    if os.path.exists(args.vcf[0]):
        vcf = args.vcf[0]
        print('vcf:' + vcf)
    else:
        raise Exception('vcf does not exist')
    if os.path.exists(args.dbSNP[0]):
        dbsnp = args.dbSNP[0]
        print('dbSNP:' + dbsnp)
    else:
        raise Exception('dbSNP does not exist')
    if args.hg19To38:
        convert_type = 'hg19To38'
    elif args.hg38To19:
        convert_type = 'hg38To19'
    else:
        raise Exception('convert type error')
    rsid_mapping = dict()
    rdbsnp = open(dbsnp,'r')
    for dbsnp_line in rdbsnp:
        clean_dbsnp_line = dbsnp_line.rstrip('\r\n')
        if not clean_dbsnp_line or clean_dbsnp_line.startswith('#'):
            continue
        dbsnp_field = clean_dbsnp_line.split('\t')
        pos_info = [dbsnp_field[0],dbsnp_field[1],dbsnp_field[2],dbsnp_field[3],dbsnp_field[4]]
        pos = '\t'
        pos = pos.join(pos_info)
        rsid = dbsnp_field[5]
        rsid_mapping[rsid] = pos
    rdbsnp.close()

    rvcf = open(vcf,'r')
    output = vcf + '_' + convert_type + '.vcf'
    unmaping = vcf + '_' + convert_type + '_unmapped.vcf'
    wvcf = open(output,'w')
    wunmap = open(unmaping,'w')
    for vcf_line in rvcf:
        clean_vcf_line = vcf_line.rstrip('\r\n')
        if not clean_vcf_line or clean_vcf_line.startswith('#'):
            continue
        vcf_fields = clean_vcf_line.split("\t")
        rsid = vcf_fields[2]
        filter = vcf_fields[5]
        info = vcf_fields[6]
        format = vcf_fields[7]
        content = vcf_fields[8]
        if rsid[0] == 'r' and rsid[1] == 's':
            if rsid in rsid_mapping:
                print('mapping:' + rsid)
                mapping_pos = rsid_mapping[rsid]
                vcf_info = [mapping_pos,filter,info,format,content]
                vcf_content = '\t'
                vcf_content = vcf_content.join(vcf_info)
                wvcf.write(vcf_content + '\n')
            else:
                print('unmapping:' + rsid)
                wunmap.write(rsid + '\n')
            '''
            cmd = ['/bin/grep', '-w', rsid, dbsnp]
            result = run(cmd, stdout=PIPE, stderr=PIPE, universal_newlines=True)
            if result.returncode == 0:
                position = result.stdout
                clean_pos = position.rstrip('\n$')
                match_multi = re.match('\n',clean_pos)
                if match_multi:
                    print('multi alt:')
                    multi_alt = match_multi.split('\n')
                    for alt in multi_alt:
                        print(alt)
                else:
                    print('single alt:')
                    print(clean_pos)
                    #print(clean_pos)
                    #print(result.stdout)
            else:
                print(result.stderr)
                #print(result.returncode, result.stdout, result.stderr)'''
        else:
            continue
    rvcf.close()
    wvcf.close()
    wunmap.close()

if __name__ == '__main__':
    main()

