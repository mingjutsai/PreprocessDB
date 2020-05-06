#!/usr/bin/python3
import argparse
import os
import csv

def parse_arguments():
    parser = argparse.ArgumentParser(prog='transfer csv to annovar format',
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

    header = ['#Chr','Start','End','Ref','Alt','Gene_Ensembl']
    tab = '\t'
    o_output_file = open(output_file, 'w')
    header_info = tab.join(header)
    o_output_file.write(f'{header_info}\n')
    count = 0
    with open(input_file,'rt') as f:
        csv_reader = csv.reader(f)
        for line in csv_reader:
            if line[2] == 'chr':
                    continue
            info = [line[2], line[3], line[3], line[4], line[5], line[1]]
            print_info = tab.join(info)
            o_output_file.write(f'{print_info}\n')
            count += 1

    print(f'finish {count} variants')
    o_output_file.close()
    f.close()

if __name__ == "__main__":
    main()
