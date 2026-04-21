#!/usr/bin/perl
# pre2homer.pl — Convert juicer .pre file to HOMER Hi-C pairs format
#
# Input (.pre, 11 columns, space/tab separated):
#   readname str1 chr1 pos1 frag1 str2 chr2 pos2 frag2 mapq1 mapq2
#   str: 0=forward, 16=reverse (SAM flags)
#   chr: no "chr" prefix (e.g. "1", "2", "X")
#
# Output (HOMER pairs format, 7 columns):
#   pairID  chr1  pos1  strand1  chr2  pos2  strand2
#
# Filters: MAPQ >= 30, cis-only (chr1 == chr2), autosomes + X + Y
#
# Usage: perl pre2homer.pl <input.pre> <output.homer>

use strict;
use warnings;

my ($input, $output) = @ARGV;
if (@ARGV < 2) {
    print STDERR "Usage: perl pre2homer.pl input.pre output.homer\n";
    die;
}

my %valid_chr = map { $_ => 1 } (1..22, "X", "Y");
my $no = 1;

open(IN,  "<", $input)  or die "Cannot open $input: $!";
open(OUT, ">", $output) or die "Cannot open $output: $!";

while (my $line = <IN>) {
    chomp $line;
    my @e = split(/\t/, $line);
    next if @e < 11;

    my ($str1, $chr1, $pos1) = @e[1,2,3];
    my ($str2, $chr2, $pos2) = @e[5,6,7];
    my ($mapq1, $mapq2)      = @e[9,10];

    # MAPQ filter
    next if $mapq1 < 30 or $mapq2 < 30;

    # Cis only
    next if $chr1 ne $chr2;

    # Valid chromosomes only
    next unless $valid_chr{$chr1};

    # Convert SAM strand flag to +/-
    my $strand1 = ($str1 == 16) ? "-" : "+";
    my $strand2 = ($str2 == 16) ? "-" : "+";

    # Add chr prefix
    my $c1 = "chr" . $chr1;
    my $c2 = "chr" . $chr2;

    print OUT "$no\t$c1\t$pos1\t$strand1\t$c2\t$pos2\t$strand2\n";
    $no++;
}

close IN;
close OUT;
print STDERR "Done. Written ${\($no-1)} pairs to $output\n";
