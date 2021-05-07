#!/usr/bin/perl
use strict;
use warnings;
my $cmd = "./SPrediXcan.py ";
#$cmd .= "--model_db_path /mnt/Storage1/ifar/predictdb/eqtl/mashr/mashr_Lung.db ";
#$cmd .= "--covariance /mnt/Storage1/ifar/predictdb/eqtl/mashr/mashr_Lung.txt.gz ";
$cmd .= "--model_db_path /mnt/Storage1/ifar/predictdb/eqtl/mashr/mashr_Whole_Blood.db ";
$cmd .= "--covariance  /mnt/Storage1/ifar/predictdb/eqtl/mashr/mashr_Whole_Blood.txt.gz ";
#$cmd .= "--gwas_file /mnt/Storage1/ifar/COVID-19/covid19-hg/ANA_B2_V2/COVID19_HGI_ANA_B2_V2_20200701.txt.gz_eQTL_id.txt.gz ";
$cmd .= "--gwas_file /mnt/Storage1/ifar/COVID-19/covid19-hg/ANA_A2_V2/COVID19_HGI_ANA_A2_V2_20200701.txt.gz_eQTL_id.txt.gz ";
$cmd .= "--snp_column eQTL_ID ";
$cmd .= "--effect_allele_column ALT ";
$cmd .= "--non_effect_allele_column REF ";
$cmd .= "--beta_column all_inv_var_meta_beta ";
$cmd .= "--pvalue_column all_inv_var_meta_p ";
$cmd .= "--keep_non_rsid ";
$cmd .= "--additional_output ";
$cmd .= "--model_db_snp_key varID ";
$cmd .= "--throw ";
#$cmd .= "--output_file /mnt/Storage1/ifar/COVID-19/covid19-hg/ANA_B2_V2/SPrediXcan_results/SPrediXcan_Lung_results.csv";
$cmd .= "--output_file /mnt/Storage1/ifar/COVID-19/covid19-hg/ANA_A2_V2/SPrediXcan_results/SPrediXcan_Whole_Blood_results.csv";
print STDERR $cmd."\n";
`$cmd`;





