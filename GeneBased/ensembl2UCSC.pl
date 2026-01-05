#!/usr/bin/perl
use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
my ($program,$gtf,$build,$src_dir,$input_dir);
my ($gtf_gene,$predGene_process,$gtf2GenePred,$hg2GRCh,$process,$gene2fa,$final);
my $command;
$program = abs_path($0);
$src_dir = dirname($program);
$gtf = $ARGV[0];
$build = $ARGV[1];
if(@ARGV < 2){
	print STDERR "Usage:perl $program [GTF File] {19/38}\n";
	exit;
}
$input_dir = dirname($gtf);
$gtf_gene = $gtf."_GenePred";
$predGene_process = $gtf_gene."_process";
$gtf2GenePred = "/home/mingju/miniforge3/bin/gtfToGenePred";
$hg2GRCh = $src_dir."/hg19_GRCh37";
$process = $src_dir."/process_genePred.pl";
$gene2fa = $src_dir."/gene2fa.pl";
$final = $input_dir."/hg38_ensGene.txt";
if(!-e $gtf2GenePred){
	print STDERR "$gtf2GenePred does not exist\n";die;
}
if(!-e $hg2GRCh){
	print STDERR "$hg2GRCh does not exist\n";die;
}
if(!-e $process){
	print STDERR "$process does not exist\n";die;
}
if(!-e $gene2fa){
	print STDERR "$gene2fa does not exist\n";die;
}
$command = "$gtf2GenePred -genePredExt -geneNameAsName2 $gtf $gtf_gene";
print STDERR "$command\n";
`$command`;
$command = "perl $process $hg2GRCh $gtf_gene";
print STDERR "$command\n";
`$command`;
$command = "perl $gene2fa $predGene_process $build ensGene";
print STDERR "$command\n";
`$command`;
$command = "cp $predGene_process $final";
print STDERR "$command\n";
`$command`;
