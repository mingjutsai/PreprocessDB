#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "trans2eQTL.pl input\n";die;
}
my $output = $input."_eQTL_id.txt";
open OUT,">",$output;
if($input =~ /\.gz$/){
    open(IN, "gunzip -c $input |") || die "can't open pipe to ".$input."\n";
}else{
    open IN,"<",$input;
}
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
	print OUT $line."\teQTL_ID\n";
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $pos = $ele[1];
    my $ref = $ele[2];
    my $alt = $ele[3];
    my $id = "chr".$chr."_".$pos."_".$ref."_".$alt."_b38";
    print OUT $line."\t".$id."\n";
}
close OUT;
close IN;

