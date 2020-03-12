#!/usr/bin/perl
use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
my ($program,$src_dir,$retrieve_seq);
my ($genefile,$hg,$db,$hg19_seq,$hg38_seq,$seq_path);
my $command;
my $output;
$program = abs_path($0);
$src_dir = dirname($program);
$retrieve_seq = $src_dir."/retrieve_seq_from_fasta.pl";
if(!-e $retrieve_seq){
	print STDERR "retrieve_seq function <$retrieve_seq> does not exist\n";die;
}
$genefile = $ARGV[0];
$hg = $ARGV[1];
$db = $ARGV[2];
$hg19_seq = "/STORAGE/reference/hg19seq";
$hg38_seq = "/STORAGE/reference/hg38seq";
if (@ARGV < 3){
	print "Usage: perl $program [FILE] [19.38] [ensGene,refGene,ccdsGene,knownGene,genericGene]\n";
	exit;
}
if(($hg != 19)and($hg != 38)){
	print STDERR "buildver is error\n";die;
}
if(($db ne "ensGene")and($db ne "refGene")and($db ne "ccdsGene")and($db ne "knownGene")and($db ne "genericGene")){
	print STDERR "db is error\n";die;
}
if($hg == 19){
	$seq_path = $hg19_seq;
}elsif($hg == 38){
	$seq_path = $hg38_seq;
}
$output = "hg".$hg."_".$db."Mrna.fa";
$command = "perl $retrieve_seq -format $db -seqdir $seq_path -outfile $output $genefile";
print STDERR "$command\n";
`$command`;
