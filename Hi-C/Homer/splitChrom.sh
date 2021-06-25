input=$1
mkdir split_results
for chr in `cut -f 3 $input | sort | uniq`; do
   grep -w $chr $input > split_results/${chr}.sigInteractions.txt
done
