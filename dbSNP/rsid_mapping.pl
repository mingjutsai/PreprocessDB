#!/usr/bin/perl
use strict;
use warnings;
my $dbsnp = $ARGV[0];
my $input1 = $ARGV[1];
my $input2 = $ARGV[2];
my %rsid;
open DBSNP,"<",$dbsnp;
my $line=<DBSNP>;
while($line=<DBSNP>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $rsid = $ele[5];
    $rsid{$rsid} = $ele[0]."\t".$ele[1]."\t".$ele[2]."\t".$ele[3]."\t".$ele[4];
}
close DBSNP;

my $out1 = $input1."_hg38.vcf";
open OUT1,">",$out1;
open IN1,"<",$input1;
$line=<IN1>;
print OUT1 $line;
while($line=<IN1>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $rsid = $ele[2];
    my $pos = $rsid{$rsid};
    print OUT1 $pos."\t".$ele[5]."\t".$ele[6]."\t".$ele[7]."\t".$ele[8]."\n";
}
close IN1;
close OUT1;

my $out2 = $input2."_hg38.vcf";
open OUT2,">",$out2;
open IN2,"<",$input2;
$line=<IN2>;
print OUT2 $line;
while($line=<IN2>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $rsid = $ele[2];
    my $pos = $rsid{$rsid};
    print OUT2 $pos."\t".$ele[5]."\t".$ele[6]."\t".$ele[7]."\t".$ele[8]."\n";
}
close IN2;
close OUT2;
