#!/usr/bin/python3
import argparse
import os

def parse_arguments():
    parser = argparse.ArgumentParser(prog='transfer dbNSFP 4.0a to annovar format',
                                     description='')
    parser.add_argument('input', type=str, nargs=1,
    help='input data with path')
    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    if os.path.exists(args.input[0]):
        input_file = args.input[0]
        output_file = input_file + '_annovar'
        print(f'input file is {input_file}, output file is {output_file}')
    else:
        raise Exception('input file is not exist')

    header = ['#Chr','Start','End','Ref','Alt','dbNSFP_gene_name','dbNSFP_Ensembl_transcriptid']
    header += ['SIFT_score','SIFT_converted_rankscore','SIFT_pred']
    header += ['SIFT4G_score','SIFT4G_converted_rankscore','SIFT4G_pred']
    header += ['Polyphen2_HDIV_score','Polyphen2_HDIV_rankscore','Polyphen2_HDIV_pred']
    header += ['Polyphen2_HVAR_score','Polyphen2_HVAR_rankscore','Polyphen2_HVAR_pred']
    header += ['LRT_score','LRT_converted_rankscore','LRT_pred']
    header += ['MutationTaster_score','MutationTaster_converted_rankscore','MutationTaster_pred']
    header += ['MutationAssessor_rankscore','MutationAssessor_pred']
    header += ['FATHMM_score','FATHMM_converted_rankscore','FATHMM_pred']
    header += ['PROVEAN_score','PROVEAN_converted_rankscore','PROVEAN_pred']
    header += ['MetaSVM_score','MetaSVM_rankscore','MetaSVM_pred']
    header += ['MetaLR_score','MetaLR_rankscore','MetaLR_pred','Reliability_index']
    header += ['M-CAP_score','M-CAP_rankscore','M-CAP_pred']
    header += ['PrimateAI_score','PrimateAI_rankscore','PrimateAI_pred']
    header += ['DEOGEN2_score','DEOGEN2_rankscore','DEOGEN2_pred']
    header += ['Aloft_Fraction_transcripts_affected','Aloft_prob_Tolerant','Aloft_prob_Recessive','Aloft_prob_Dominant','Aloft_pred','Aloft_Confidence']
    tab = '\t'
    o_output_file = open(output_file, 'w')
    header_info = tab.join(header)
    o_output_file.write(f'{header_info}\n')

    r_input_file = open(input_file,'r')
    count = 0
    for line in r_input_file:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split('\t')
        if fields[0] == '#chr':
            continue
        info = [fields[0],fields[1],fields[1],fields[2],fields[3],fields[12],fields[14]]
        #chr:0
        #pos:1
        #ref:2
        #alt:3
        #genename:12
        #Ensembl_transcriptid:14
        info += [fields[36],fields[37],fields[38]]
        #SIFT_score:36
        #SIFT_converted_rankscore:37
        #SIFT_pred:38
        info += [fields[39],fields[40],fields[41]]
        #SIFT4G_score:39
        #SIFT4G_converted_rankscore:40
        #SIFT4G_pred:41
        info += [fields[42],fields[43],fields[44]]
        #Polyphen2_HDIV_score:42
        #Polyphen2_HDIV_rankscore:43
        #Polyphen2_HDIV_pred:44
        info += [fields[45],fields[46],fields[47]]
        #Polyphen2_HVAR_score:45
        #Polyphen2_HVAR_rankscore:46
        #Polyphen2_HVAR_pred:47
        info += [fields[48],fields[49],fields[50]]
        #LRT_score:48
        #LRT_converted_rankscore:49
        #LRT_pred:50
        info += [fields[52],fields[53],fields[54]]
        #MutationTaster_score:52
        #MutationTaster_converted_rankscore:53
        #MutationTaster_pred:54
        info += [fields[58],fields[59]]
        #MutationAssessor_rankscore:58
        #MutationAssessor_pred:59
        info += [fields[60],fields[61],fields[62]]
        #FATHMM_score:60
        #FATHMM_converted_rankscore:61
        #FATHMM_pred:62
        info += [fields[63],fields[64],fields[65]]
        #PROVEAN_score:63
        #PROVEAN_converted_rankscore:64
        #PROVEAN_pred:65
        info += [fields[68],fields[69],fields[70]]
        #MetaSVM_score:68
        #MetaSVM_rankscore:69
        #MetaSVM_pred:70
        info += [fields[71],fields[72],fields[73],fields[74]]
        #MetaLR_score:71
        #MetaLR_rankscore:72
        #MetaLR_pred:73
        #Reliability_index:74
        info += [fields[75],fields[76],fields[77]]
        #M-CAP_score:75
        #M-CAP_rankscore:76
        #M-CAP_pred:77
        info += [fields[89],fields[90],fields[91]]
        #PrimateAI_score:89
        #PrimateAI_rankscore:90
        #PrimateAI_pred:91
        info += [fields[92],fields[93],fields[94]]
        #DEOGEN2_score:92
        #DEOGEN2_rankscore:93
        #DEOGEN2_pred:94
        info += [fields[95],fields[96],fields[97],fields[98],fields[99],fields[100]]
        #Aloft_Fraction_transcripts_affected:95
        #Aloft_prob_Tolerant:96
        #Aloft_prob_Recessive:97
        #Aloft_prob_Dominant:98
        #Aloft_pred:99
        #Aloft_Confidence:100
        scores_info = tab.join(info)
        o_output_file.write(f'{scores_info}\n')
        count += 1
    
    print(f'finish {count} variants')
    o_output_file.close()
    r_input_file.close()


if __name__ == "__main__":
    main()