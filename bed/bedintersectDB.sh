input=$1
db=$2
fraction=$3
output=$4
bedtools intersect -wa -wb -a $input -b $db -sorted -F $fraction > $output
