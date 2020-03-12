#!/usr/bin/perl
use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
my ($program,$src_dir,$retrieve_seq);
my ($genefile,$hg,$db,$seq_path,$build);
my $command;
my $output;
$program = abs_path($0);
$src_dir = dirname($program);
$retrieve_seq = $src_dir."/retrieve_seq_from_fasta.pl";
if(!-e $retrieve_seq){
	print STDERR "retrieve_seq function <$retrieve_seq> does not exist\n";die;
}
$genefile = $ARGV[0];
$seq_path = $ARGV[1];
$db = $ARGV[2];
$build = $ARGV[3];
if (@ARGV < 4){
	print "Usage: perl $program [FILE] [hg19_reference_dir,hg38_reference_dir] 
	[ensGene,refGene,ccdsGene,knownGene,genericGene] [19,38]\n";
	exit;
}

if(($db ne "ensGene")and($db ne "refGene")and($db ne "ccdsGene")and($db ne "knownGene")and($db ne "genericGene")){
	print STDERR "db is error\n";die;
}
my $output_dir = dirname($genefile);
$output = $output_dir."/hg".$build."_".$db."Mrna.fa";
$command = "perl $retrieve_seq -format $db -seqdir $seq_path -outfile $output $genefile";
print STDERR "$command\n";
`$command`;
