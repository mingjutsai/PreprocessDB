#!/usr/bin/perl
use strict;
use warnings;

my @chrs = (1..22, "X", "Y");
my $merge = "cat " . join(" ", map { "chr${_}.sigInteractions.txt_peak1_peak2_FDR0.05.bed" } @chrs);
$merge .= " > allchr.sigInteractions.HOMER";
print STDERR $merge."\n";
`$merge`;
