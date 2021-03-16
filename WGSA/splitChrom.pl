#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

my $input = $ARGV[0];
my $type = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl splitChrom_WGSA2annovar.pl WGSA_input type(missense, others)\n";die;
}
if(($type ne "missense")and($type ne "others")){
    print STDERR "type is error\n";die;
}
my $filename = basename($input);
my $output;
my $chr_orig = "Z";
open IN,"<",$input;
my $line=<IN>;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    if($chr ne $chr_orig){
       my $chr_dir = "chr".$chr;
       if(!-d $chr_dir){
	   #print STDERR "mkdir ".$chr_dir."\n";
	   my $cmd = "mkdir ".$chr_dir;
	   print STDERR $cmd."\n";
	   `$cmd`;
       }
       $output = $chr_dir."/".$filename."_Chr".$chr."_annovar";
       open OUT,">",$output;
       if($type eq "missense"){
           print OUT "#Chr\tStart\tEnd\tRef\tAlt\tChr_19\tPos_19\tRef_19\tAlt_19\tGene\n";
       }
       $chr_orig = $chr;
    }
    print OUT $line."\n";
}
close IN;
close OUT;
