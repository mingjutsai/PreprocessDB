#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl meta2annovar_v2.pl meta-analysis\n;";die;
}
my $output = $input."_annovar";
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tN\tP\tOR\n";

open IN,"<",$input;
my $line=<IN>;
while($line=<IN>){
    chomp $line;
    my @ele = split(/ /,$line);
    my $chr = $ele[0];
    my $pos = $ele[1];
    my $a1 = $ele[3];
    my $a2 = $ele[4];
    my $pos_end = $pos + length($a1) - 1;
    my $n = $ele[5];
    my $p = $ele[6];
    my $or = $ele[7];
    my $info = join("\t",$chr,$pos,$pos_end,$a1,$a2,$n,$p,$or);
    print OUT $info."\n";
}
close IN;
close OUT;
