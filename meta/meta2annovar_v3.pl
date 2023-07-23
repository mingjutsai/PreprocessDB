#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV<1){
    print STDERR "perl parse_meta.pl meta_analysis\n";die;
}
my $output = $input."_annovar";
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
print OUT "#Chr\tStart\tEnd\tRef\tAlt\t".$header;

while($line=<IN>){
    chomp $line;
    $line =~ s/ /\t/g;
    @ele = split(/\t/,$line);
    my $pos_info = $ele[0];
    my ($chr,$pos,$ref,$alt) = split(/:/,$pos_info);
    #my ($chr,$pos,$ref,$alt) = split(/:/,$pos_info);
    if($chr eq '23'){
        $chr = 'X';
    }elsif($chr eq '24'){
        $chr = 'Y';
    }elsif($chr eq '25'){
       $chr = 'M';
    }
    my $start = $pos + 0;
    my $end = $pos + length($ref) - 1;
    my $info;
    print OUT $chr."\t".$start."\t".$end."\t".$ref."\t".$alt."\t";
    for(my $i=1; $i<$column_no; $i++){
        $info .= $ele[$i]."\t";
    }
    $info =~ s/\t$/\n/;
    print OUT $info;
}
close IN;
close OUT;
