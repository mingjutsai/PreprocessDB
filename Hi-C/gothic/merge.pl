$merge = "cat ";
for($i=1;$i<=24;$i++){
        $merge .= "chr".$i."_gothic.results_peak1_peak2_res.2000.bed ";
	#}
}
$merge .= "> allchr.sigInteractions.gothic";
print STDERR $merge."\n";
`$merge`;
