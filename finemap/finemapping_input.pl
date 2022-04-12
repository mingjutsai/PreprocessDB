#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $output = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl finemapping rsid.locus.txt output\n";die;
}
open OUT,">",$output;
print OUT "rsid chromosome position noneff_allele eff_allele maf beta se\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^SNP/){
        next;
    }
    my @ele = split(/\t/,$line);
    my @pos = split(/[:\_]/,$ele[0]);
    my $chr = $pos[0];
    my $pos = $pos[1];
    #print STDERR "chr:".$pos[0]."\tpos:".$pos[1]."\n";die;
    my $id = $ele[0];
    my $noneff_a = $ele[1];
    my $eff_a = $ele[2];
    my $maf = $ele[3];
    if($maf > 0.5){
        $maf = 1 - $maf;
    }
    my $beta = $ele[4];
    my $se = $ele[5];
    print OUT $id." ".$chr." ".$pos." ".$noneff_a." ".$eff_a." ".$maf." ".$beta." ".$se."\n";

}
close IN;
close OUT;
