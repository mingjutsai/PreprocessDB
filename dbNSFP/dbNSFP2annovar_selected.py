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
        output_file = input_file + '_annovar_ensembl_scores'
        print(f'input file is {input_file}, output file is {output_file}')
    else:
        raise Exception('input file is not exist')

    header = ['#Chr','Start','End','Ref','Alt']
    header += ['MetaSVM_pred','MetaLR_pred']
    header += ['CADD_pred','REVEL_pred']
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
        info = [fields[0],fields[1],fields[1],fields[2],fields[3]]
        #chr:0
        #pos:1
        #ref:2
        #alt:3
        
        info += [fields[70],fields[73]]
        #MetaSVM_pred:70
        #MetaLR_pred:73
        revel_score = fields[78]
        if revel_score == '.':
            revel_pred = '.'
        else:
            revel_score = float(fields[78])
            if revel_score >= 0.5:
                revel_pred = 'D'
            else:
                revel_pred = 'T'
        cadd_score = fields[101]
        if cadd_score == '.':
            cadd_pred = '.'
        else:
            cadd_score = float(fields[101])
            if cadd_score >= 30:
                cadd_pred = 'D'
            else:
                cadd_pred = 'T'
        info += [cadd_pred,revel_pred]
        scores_info = tab.join(info)
        o_output_file.write(f'{scores_info}\n')
        count += 1
    
    print(f'finish {count} variants')
    o_output_file.close()
    r_input_file.close()


if __name__ == "__main__":
    main()
