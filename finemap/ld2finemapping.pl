#!/usr/bin/perl
use strict;
use warnings;
my $in = $ARGV[0];
my $out = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl ld2finemapping.pl input output\n";die;
}
open OUT,">",$out;
open IN,"<",$in;
while(my $line=<IN>){
    chomp $line;
    $line =~ s/\t/ /g;
    print OUT $line."\n";
}
close IN;
