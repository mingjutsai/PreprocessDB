#!/usr/bin/python3
import argparse
import os
def parse_arguments():
    parser = argparse.ArgumentParser(prog='transfer to annovar format.',
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
    o_output_file = open(output_file, 'w')
    o_output_file.write('#Chr\tStart\tEnd\tRef\tAlt\tRsid\n')
    r_input_file = open(input_file,'r')
    count = 0
    for line in r_input_file:
        clean_line = line.rstrip('\r\n')
        fields = clean_line.split(' ')
        chr = fields[0].replace('chr', '')
        #print(f'{chr},{fields[2]},{fields[3]},{fields[4]},{fields[6]}')
        start = int(fields[2])
        rsid = fields[3]
        ref = fields[4]
        alt = fields[6]
        end = start + len(ref) - 1
        o_output_file.write(f'{chr}\t{start}\t{end}\t{ref}\t{alt}\t{rsid}\n')
        count += 1

    print(f'Finish the transfer {count} variants')

if __name__ == "__main__":
    main()


