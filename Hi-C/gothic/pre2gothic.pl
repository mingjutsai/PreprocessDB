#!/usr/bin/perl
# pre2gothic.pl — Convert juicer .pre file to per-chromosome GOTHiC format
#
# Input (.pre, 11 columns):
#   readname str1 chr1 pos1 frag1 str2 chr2 pos2 frag2 mapq1 mapq2
#   str: 0=forward, 16=reverse (SAM flags)
#   chr: no "chr" prefix (e.g. "1", "2", "X")
#
# Output: one file per chromosome (e.g. <prefix>_chr1.gothic)
#   2 lines per pair (GOTHiC format):
#   readname  flag  chr  pos
#   readname  flag  chr  pos
#
# Filters: MAPQ >= 30, cis-only, autosomes + X + Y
#
# Usage: perl pre2gothic.pl <input.pre> <sample_prefix> <outdir>
# Example: perl pre2gothic.pl mergedOC.bam.pre mergedOC gothic/

use strict;
use warnings;

my ($input, $prefix, $outdir) = @ARGV;
if (@ARGV < 3) {
    print STDERR "Usage: perl pre2gothic.pl input.pre sample_prefix outdir\n";
    die;
}

my %valid_chr = map { $_ => 1 } (1..22, "X", "Y");

mkdir $outdir unless -d $outdir;

my %fh;
for my $c (1..22, "X", "Y") {
    my $fname = "$outdir/${prefix}_chr${c}.gothic";
    open $fh{$c}, ">", $fname or die "Cannot open $fname: $!";
}

my $total = 0;
my $written = 0;

open(IN, "<", $input) or die "Cannot open $input: $!";
while (my $line = <IN>) {
    chomp $line;
    my @e = split(/\t/, $line);
    next if @e < 11;

    my ($name, $str1, $chr1, $pos1) = @e[0,1,2,3];
    my ($str2, $chr2, $pos2)        = @e[5,6,7];
    my ($mapq1, $mapq2)             = @e[9,10];

    $total++;
    print STDERR "  ... $total pairs processed\n" if $total % 50_000_000 == 0;

    next if $mapq1 < 30 or $mapq2 < 30;
    next if $chr1 ne $chr2;
    next unless $valid_chr{$chr1};

    my $fh = $fh{$chr1};
    print $fh "$name\t$str1\tchr$chr1\t$pos1\n";
    print $fh "$name\t$str2\tchr$chr2\t$pos2\n";
    $written++;
}
close IN;

for my $c (1..22, "X", "Y") { close $fh{$c}; }

print STDERR "Done. Total pairs: $total, Written cis MAPQ>=30: $written\n";
