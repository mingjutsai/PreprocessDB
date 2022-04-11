import re

def main():
    leadSNP = "FUMA_job167139_t2d/GenomicRiskLoci.txt"
    annovar = leadSNP + ".annovar"
    wfile = open(annovar, 'w')
    wfile.write("#Chr\tStart\tEnd\tRef\tAlt\tID\tRSID\tP-value\n")
    rfile = open(leadSNP,"r")
    for line in rfile:
        clean_line = line.rstrip('\r\n')
        ele = clean_line.split('\t')
        id = ele[1]
        if id == 'uniqID':
            continue
        rsid = ele[2]
        id_arr = re.split(':', id)
        chr = id_arr[0]
        pos = id_arr[1]
        a1 = id_arr[2]
        a2 = id_arr[3]
        pvalue = ele[5]
        end = int(pos) + len(a1) - 1
        content = chr + "\t" + pos + "\t" + str(end) + "\t" + a1 + "\t" + a2 + "\t" + id + "\t" + rsid + "\t" + pvalue
        wfile.write(content + "\n")
        #print(content)
        #print(chr + ":" + pos + "_" + a1 + "_" + a2)
    wfile.close()
    rfile.close()


if __name__ == "__main__":
    main()
