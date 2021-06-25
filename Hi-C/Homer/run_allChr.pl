#!/usr/bin/perl
use strict;
use warnings;
for(my $i=1;$i<=25;$i++){
    my $cmd = "perl ~/PreprocessDB/Hi-C/Homer/homer2bed_simple.pl chr".$i.".sigInteractions.txt 0.05";
    print $cmd."\n";
    `$cmd`;
}
