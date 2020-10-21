input=$1
output=${input}"_sorted_lexicographical"
#echo $output
sort -k1,1 -k2,2n $input > $output 
