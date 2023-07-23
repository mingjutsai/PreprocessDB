#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV <1){
    print STDERR "perl splitByChrom.pl input\n";die;
}
my $chr1 = $input."_chr1";
open CHR1,">",$chr1;

my $chr2 = $input."_chr2";
open CHR2,">",$chr2;

my $chr3 = $input."_chr3";
open CHR3,">",$chr3;

my $chr4 = $input."_chr4";
open CHR4,">",$chr4;

my $chr5 = $input."_chr5";
open CHR5,">",$chr5;

my $chr6 = $input."_chr6";
open CHR6,">",$chr6;

my $chr7 = $input."_chr7";
open CHR7,">",$chr7;

my $chr8 = $input."_chr8";
open CHR8,">",$chr8;

my $chr9 = $input."_chr9";
open CHR9,">",$chr9;

my $chr10 = $input."_chr10";
open CHR10,">",$chr10;

my $chr11 = $input."_chr11";
open CHR11,">",$chr11;

my $chr12 = $input."_chr12";
open CHR12,">",$chr12;

my $chr13 = $input."_chr13";
open CHR13,">",$chr13;

my $chr14 = $input."_chr14";
open CHR14,">",$chr14;

my $chr15 = $input."_chr15";
open CHR15,">",$chr15;

my $chr16 = $input."_chr16";
open CHR16,">",$chr16;

my $chr17 = $input."_chr17";
open CHR17,">",$chr17;

my $chr18 = $input."_chr18";
open CHR18,">",$chr18;

my $chr19 = $input."_chr19";
open CHR19,">",$chr19;

my $chr20 = $input."_chr20";
open CHR20,">",$chr20;

my $chr21 = $input."_chr21";
open CHR21,">",$chr21;

my $chr22 = $input."_chr22";
open CHR22,">",$chr22;

my $chrX = $input."_chrX";
open CHRX,">",$chrX;

my $chrY = $input."_chrY";
open CHRY,">",$chrY;

my $chrMT = $input."_chrMT";
open CHRMT,">",$chrMT;


open IN,"<",$input;
my $line=<IN>;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    if($chr eq "1"){
        print CHR1 $line."\n";
    }elsif($chr eq "2"){
        print CHR2 $line."\n";
    }elsif($chr eq "3"){
        print CHR3 $line."\n";
    }elsif($chr eq "4"){
        print CHR4 $line."\n";
    }elsif($chr eq "5"){
        print CHR5 $line."\n";
    }elsif($chr eq "6"){
        print CHR6 $line."\n";
    }elsif($chr eq "7"){
        print CHR7 $line."\n";
    }elsif($chr eq "8"){
        print CHR8 $line."\n";
    }elsif($chr eq "9"){
        print CHR9 $line."\n";
    }elsif($chr eq "10"){
        print CHR10 $line."\n";
    }elsif($chr eq "11"){
        print CHR11 $line."\n";
    }elsif($chr eq "12"){
        print CHR12 $line."\n";
    }elsif($chr eq "13"){
        print CHR13 $line."\n";
    }elsif($chr eq "14"){
        print CHR14 $line."\n";
    }elsif($chr eq "15"){
        print CHR15 $line."\n";
    }elsif($chr eq "16"){
        print CHR16 $line."\n";
    }elsif($chr eq "17"){
        print CHR17 $line."\n";
    }elsif($chr eq "18"){
        print CHR18 $line."\n";
    }elsif($chr eq "19"){
        print CHR19 $line."\n";
    }elsif($chr eq "20"){
        print CHR20 $line."\n";
    }elsif($chr eq "21"){
        print CHR21 $line."\n";
    }elsif($chr eq "22"){
        print CHR22 $line."\n";
    }elsif($chr eq "X"){
        print CHRX $line."\n";
    }elsif($chr eq "Y"){
       print CHRY $line."\n";
    }elsif($chr eq "M"){
        print CHRMT $line."\n";
    }
}
close IN;
