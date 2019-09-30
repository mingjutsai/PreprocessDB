import argparse
import os
# initiate the parser
def parse_arguments():
    parser = argparse.ArgumentParser(prog='Transfer Gefos data to vcf/annovar format.',
                                        description='')

    # add long and short argument
    parser.add_argument('input', type=str, nargs=1,
                        help='Path for Gefos file.')
    parser.add_argument('--Bmd', action="store_true", help='Process Biobank2-British-FracA-As-C-Gwas-SumStats.txt')
    parser.add_argument('--FracA', action="store_true", help='Process Biobank2-British-Bmd-As-C-Gwas-SumStats.txt')
    parser.add_argument('--vcf', action="store_true", help='transfer to vcf.')
    parser.add_argument('--annovar', action="store_true", help='transfer to annovar')
    # read arguments from the command line
    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    if args.vcf:
        transfer_status = 'vcf'
    elif args.annovar:
        transfer_status = 'annovar'
    if args.Bmd:
        gwas_type = 'bmd'
    elif args.FracA:
        gwas_type = 'fraca'
    if os.path.exists(args.input[0]):
        gefos = args.input[0]
        print('#gefos:' + gefos)
    else:
        raise Exception('input file does not exist')
    if transfer_status == 'vcf':
        output = gefos + '.vcf'
        wfile = open(output,'w')
        if  gwas_type == 'bmd':
            wfile.write('#CHROM\tPOS\tID\tREF\tALT\tFILTER\tINFO\tFORMAT\tGEFOS_Bmd\n')
        elif gwas_type == 'fraca':
            wfile.write('#CHROM\tPOS\tID\tREF\tALT\tFILTER\tINFO\tFORMAT\tGEFOS_fracA\n')
        rfile = open(gefos,"r")
        for line in rfile:
            clean_line = line.rstrip('\r\n')
            fields = clean_line.split("\t")
            snpid = fields[0]
            if snpid == 'SNPID':
                continue
            rsid = fields[1]
            chr = fields[2]
            pos = fields[3]
            ref = fields[4]
            alt = fields[5]
            filter = '.'
            info = 'NA'
            if gwas_type == 'bmd':
                format = 'EAF:INFO:BETA:SE:P:P.I:P.NI:N'
                #fields[6]:EAF
                #fields[7]:INFO
                #fields[8]:BETA
                #fields[9]:SE
                #fields[10]:P
                #fields[11]:P.I
                #fields[12]:P.NI
                #fields[13]:N
                content_list = [fields[6],fields[7],fields[8],fields[9],fields[10],
                                fields[11],fields[12],fields[13]]
                content = ':'
                content = content.join(content_list)
                #content = fields[6] + ':' + fields[7] + ':' + fields[8] + ':' + fields[9] \
                #        + ':' + fields[10] + ':' + fields[11] + ':' + fields[12] + ':' + fields[13] 
            elif gwas_type == 'fraca':
                format = 'A1FREQ:INFO:logOR:logOR.SE:OR:L95:U95:P:P.I:P.NI:N'
                #fields[6]:A1FREQ
                #fields[7]:INFO
                #fields[8]:logOR
                #fields[9]:logOR.SE
                #fields[10]:OR
                #fields[11]:L95
                #fields[12]:U95
                #fields[13]:P
                #fields[14]:P.I
                #fields[15]:P.NI
                #fields[16]:N
                content_list = [fields[6],fields[7],fields[8],fields[9],fields[10],
                                fields[11],fields[12],fields[13],fields[14],fields[15],fields[16]]
                content = ':'
                content = content.join(content_list)
                #content = fields[6] + ':' + fields[7] + ':' + fields[8] + ':' + fields[9] \
                #        + ':' + fields[10] + ':' + fields[11] + ':' + fields[12] + ':' + fields[13] \
                #        + ':' + fields[14] + ':' + fields[15] + ':' + fields[16]
            vcf_info = [chr,pos,rsid,ref,alt,filter,info,format,content]
            vcf_content = '\t'
            vcf_content = vcf_content.join(vcf_info)
            wfile.write(vcf_content + '\n')
            #wfile.write(chr + '\t' + pos + '\t' + rsid + '\t' + ref + '\t' + alt + '\t' +
            #            filter + '\t' + info + '\t' + format + '\t' + content + '\n')
        rfile.close()
        wfile.close()
    elif transfer_status == 'annovar':
        output = gefos + '_annovar'
        wfile = open(output,'w')
        if gwas_type == 'bmd':
           bmd_header_list = [EAF,INFO,BETA,SE,P,P.I,P.NI,N]
           header = '\t'
        elif gwas_type == 'fraca':
            fraca_header_list = [A1FREQ,INFO,logOR,logOR.SE,OR,L95,U95,P,P.I,P.NI,N]
        header = '\t'
        header = header.join(header_list)
        wfile.write('#Chr\tStart\tEnd\tRef\tAlt\t' + header_list + '\n')
        rfile = open(gefos,"r")
        for line in rfile:
            clean_line = line.rstrip('\r\n')
            fields = clean_line.split('\t')
            match_header = re.match('^#',fields[0])
            if match_header:
                continue
            else:
                content = fields[8].split(':')
                chr = fields[0]
                start = fields[1]
                ref = fields[3]
                alt = fields[4]
                end = int(start) + len(ref) - 1
                if gwas_type == 'bmd':
                    eaf = content[0]
                    info = content[1]
                    beta = content[2]
                    se = content[3]
                    p = content[4]
                    p_i = content[5]
                    p_ni = content[6]
                    n = content[7]
                    annotation_list = [chr,start,end,ref,alt,eaf,info,beta,se,p,p_i,p_ni,n]
                elif gwas_type == 'fraca':
                    a1freq = content[0]
                    info = content[1]
                    logor = content[2]
                    logor_se = content[3]
                    OR = content[4]
                    l95 = content[5]
                    u95 = content[6]
                    p = content[7]
                    p_i = content[8]
                    p_ni = content[9]
                    n = content[10]
                    annotation_list = [chr,start,enmd,ref,alr,a1freq,info,logor,logor_se,OR,l95,u95,p,p_i,p_ni,n]
                annotation = '\t'
                annotation = annotation.join(annotation_list)
                wfile.write(annotation_list + '\n')
        rfile.close()
        wfile.close()

if __name__ == "__main__":
    main()