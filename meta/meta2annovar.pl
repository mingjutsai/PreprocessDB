#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $chr_index = $ARGV[1];
my $pos_index = $ARGV[2];
my $a1_index = $ARGV[3];
my $a2_index = $ARGV[4];
my $mac_index = $ARGV[5];
my $mac_cutoff = $ARGV[6];
if(@ARGV<7){
    print STDERR "perl parse_meta.pl meta_analysis chr_index pos_index a1_index a2_index mac_index mac_cutoff\n";die;
}
my $output = $input."_annovar_mac".$mac_cutoff;
open OUT,">",$output;
open IN,"<",$input;
my $line=<IN>;
chomp $line;
$line =~ s/ /\t/g;
my @ele = split(/\t/,$line);
my $column_no = scalar @ele;
my $header;
for(my $i=1; $i<$column_no; $i++){
    $header .= $ele[$i]."\t";
}
$header =~ s/\t$/\n/;
print OUT "#Chr\tStart\tEnd\tA1\tA2\t".$header;

while($line=<IN>){
    chomp $line;
    $line =~ s/ /\t/g;
    @ele = split(/\t/,$line);
    my $pos_info = $ele[0];
    #my ($chr,$pos,$ref,$alt) = split(/:/,$pos_info);
    my $chr = $ele[$chr_index];
    my $pos = $ele[$pos_index];
    my $a1 = uc($ele[$a1_index]);
    my $a2 = uc($ele[$a2_index]);
    if($chr eq '23'){
        $chr = 'X';
    }elsif($chr eq '24'){
        $chr = 'Y';
    }elsif($chr eq '25'){
       $chr = 'M';
    }
    my $start = $pos + 0;
    my $end = $pos + length($a1) - 1;
    my $mac_value = $ele[$mac_index];
    if($mac_value < $mac_cutoff){
        next;
    }
    my $info;
    print OUT $chr."\t".$start."\t".$end."\t".$a1."\t".$a2."\t";
    for(my $i=1; $i<$column_no; $i++){
        $info .= $ele[$i]."\t";
    }
    $info =~ s/\t$/\n/;
    print OUT $info;
}
close IN;
close OUT;
