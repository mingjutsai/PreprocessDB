#!/usr/bin/perl
use strict;
use warnings;

my $sample = $ARGV[0];
my $res    = $ARGV[1];
if (@ARGV < 2) {
    print STDERR "Usage: perl merge.pl <sample> <resolution>\n"; die;
}

my @chrs = (1..22, "X", "Y");
my $merge = "cat " . join(" ", map { "${sample}_chr${_}_gothic.results_peak1_peak2_res.${res}.bed" } @chrs);
$merge .= " > allchr.sigInteractions.gothic";
print STDERR $merge . "\n";
`$merge`;
