#!/usr/bin/perl
use strict;
use warnings;

# GOTHiChicup() output columns (0-indexed):
#   0:chr1  1:locus1  2:chr2  3:locus2  4:relCoverage1  5:relCoverage2
#   6:probability  7:expected  8:readCount  9:pvalue  10:qvalue  11:logObservedOverExpected

my $input = $ARGV[0];
my $res   = $ARGV[1];
if (@ARGV < 2) {
    print STDERR "perl gothic2bed.pl input res (e.g. 2000)\n"; die;
}

my $output = $input . "_peak1_peak2_res." . $res . ".bed";
open OUT, ">", $output or die "Cannot open $output: $!";
open IN,  "<", $input  or die "Cannot open $input: $!";

my $header = <IN>;  # skip header

while (my $line = <IN>) {
    chomp $line;
    my @ele = split(/\t/, $line);
    next if @ele < 11;

    my $chr1 = $ele[0]; $chr1 =~ s/"//g; $chr1 =~ s/^chr//;
    my $chr2 = $ele[2]; $chr2 =~ s/"//g; $chr2 =~ s/^chr//;
    next if $chr1 ne $chr2;

    my $start1    = $ele[1] + 0;
    my $start2    = $ele[3] + 0;
    my $readcount = $ele[8] + 0;
    my $qvalue    = $ele[10] + 0;

    next if $readcount < 10;
    next if $qvalue    > 0.05;

    my $bin1_id  = $chr1 . ":" . $start1 . ":" . $start2;
    my $bin2_id  = $chr2 . ":" . $start2 . ":" . $start1;
    my $qval_fmt = sprintf("%.2e", $qvalue);

    print OUT $bin1_id . "\t" . $readcount . "\t" . $qval_fmt . "\n";
    print OUT $bin2_id . "\t" . $readcount . "\t" . $qval_fmt . "\n";
}
close IN;
close OUT;
