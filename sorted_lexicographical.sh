input=$1
output=${input}"_sorted"
#echo $output
sort -k1,1 -k2,2n $input > $output 
