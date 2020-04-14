input=$1
output=${input}"_sorted"
#echo $output
sort -k1,1V -k2,2n -k3,3n $input > $output 
