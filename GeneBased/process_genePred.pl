#!/usr/bin/perl
use warnings;
use strict;
use Scalar::Util qw(looks_like_number);
use Cwd 'abs_path';
use File::Basename;
my ($convert_file,$file);
my %convert;
my ($line,@ele);
my ($program,$src_dir);
my ($out,$unmatch);
my $count;
$convert_file = $ARGV[0];
$file = $ARGV[1];
$program = abs_path($0);
$src_dir = dirname($program);
if(@ARGV<2){
	print STDERR "perl $program convert file\n";die;
}
$out = $file."_process";
$unmatch = $file."_unmatch";
open CONVERT,"<",$convert_file;
while($line=<CONVERT>){
	chomp $line;
	@ele = split(/\t/,$line);
	$convert{$ele[1]} =$ele[0];
}
close CONVERT;

open OUT,">",$out;
open FILE,"<",$file;
$count = 1;
my $hg19;
open UNMATCH,">",$unmatch;
while($line=<FILE>){
	chomp $line;
	@ele = split(/\t/,$line);
	if($convert{$ele[1]}){
		$hg19 = $convert{$ele[1]};
		print OUT "$count\t$ele[0]\t$hg19\t$ele[2]\t$ele[3]\t$ele[4]\t$ele[5]\t$ele[6]\t$ele[7]\t$ele[8]\t$ele[9]\t$ele[10]\t$ele[11]\t$ele[12]\t$ele[13]\t$ele[14]\n";
	}else{
		print UNMATCH "$ele[0]\t$ele[1]\n";
		print OUT "$count\t$ele[0]\t$ele[1]\t$ele[2]\t$ele[3]\t$ele[4]\t$ele[5]\t$ele[6]\t$ele[7]\t$ele[8]\t$ele[9]\t$ele[10]\t$ele[11]\t$ele[12]\t$ele[13]\t$ele[14]\n";
	}
	#$hg19 = $convert{$ele[1]};
	$count++;
	#die;	
}
close FILE;
