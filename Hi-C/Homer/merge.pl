$merge = "cat ";
for($i=1;$i<=24;$i++){
	#if($i == 23){
	#$merge .= "powderOC_chrX.sigInteractions.txt_peak1_peak2_FDR0.05.bed ";
	#}elsif($i == 24){
	#$merge .= "powderOC_chrY.sigInteractions.txt_peak1_peak2_FDR0.05.bed ";
	#}else{
        $merge .= "chr".$i.".sigInteractions.txt_peak1_peak2_FDR0.05.bed ";
	#}
}
$merge .= "> allchr.sigInteractions.HOMER";
print STDERR $merge."\n";
`$merge`;
