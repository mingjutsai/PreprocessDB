#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    #my $chr = $ele[1];
    #$chr =~ s/chr//;
    #$ele[1] = $chr;
    my $info;
    for(my $i=1; $i<@ele; $i++){
        $info .= $ele[$i]."\t";
    }
    $info .= $ele[0];
    print $info."\n";
}
close IN;
