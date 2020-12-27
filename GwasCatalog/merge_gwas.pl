my $cmd = "cat ";
for(my $i=1;$i<=24;$i++){
    if($i == 23){
        $cmd .= "gwas_catalog_v1.0.2-associations_e100_r2020-12-15.tsv_chrX_annovar_v2 ";
    }elsif($i == 24){
        $cmd .= "gwas_catalog_v1.0.2-associations_e100_r2020-12-15.tsv_chrY_annovar_v2 ";
    }else{
        $cmd .= "gwas_catalog_v1.0.2-associations_e100_r2020-12-15.tsv_chr".$i."_annovar_v2 ";
    }
}
$cmd .= "> gwas_catalog_v1.0.2-associations_e100_r2020-12-15.tsv_annovar";
print STDERR $cmd."\n";
`$cmd`;
