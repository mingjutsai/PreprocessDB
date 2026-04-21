#!/usr/bin/perl
# pre2homer_gothic.pl — Convert juicer .pre file to HOMER and GOTHiC formats
#                       in a single pass (avoids reading the large pre file twice)
#
# Input (.pre, 11 columns):
#   readname str1 chr1 pos1 frag1 str2 chr2 pos2 frag2 mapq1 mapq2
#
# Outputs:
#   <homer_out>            — HOMER pairs format (7-col, all cis MAPQ>=30)
#   <gothic_dir>/<prefix>_chr{N}.gothic — GOTHiC per-chr format (2 lines/pair)
#
# Usage:
#   perl pre2homer_gothic.pl <input.pre> <homer_out> <gothic_dir> <gothic_prefix>
# Example:
#   perl pre2homer_gothic.pl mergedOC.bam.pre mergedOC.homer gothic/ mergedOC

use strict;
use warnings;

my ($input, $homer_out, $gothic_dir, $gothic_prefix) = @ARGV;
if (@ARGV < 4) {
    print STDERR "Usage: perl pre2homer_gothic.pl input.pre homer_out gothic_dir gothic_prefix\n";
    die;
}

my %valid_chr = map { $_ => 1 } (1..22, "X", "Y");

mkdir $gothic_dir unless -d $gothic_dir;

# Open HOMER output
open(HOMER, ">", $homer_out) or die "Cannot open $homer_out: $!";

# Open per-chr GOTHiC filehandles
my %gfh;
for my $c (1..22, "X", "Y") {
    my $fname = "$gothic_dir/${gothic_prefix}_chr${c}.gothic";
    open $gfh{$c}, ">", $fname or die "Cannot open $fname: $!";
}

my ($total, $written) = (0, 0);
my $homer_no = 1;

open(IN, "<", $input) or die "Cannot open $input: $!";
while (my $line = <IN>) {
    chomp $line;
    my @e = split(/\t/, $line);
    next if @e < 11;

    my ($name, $str1, $chr1, $pos1) = @e[0,1,2,3];
    my ($str2,        $chr2, $pos2) = @e[5,6,7];
    my ($mapq1, $mapq2)             = @e[9,10];

    $total++;
    print STDERR "  ... $total pairs processed\n" if $total % 50_000_000 == 0;

    next if $mapq1 < 30 or $mapq2 < 30;
    next if $chr1 ne $chr2;
    next unless $valid_chr{$chr1};

    my $strand1 = ($str1 == 16) ? "-" : "+";
    my $strand2 = ($str2 == 16) ? "-" : "+";
    my $c1 = "chr$chr1";

    # HOMER: one line per pair
    print HOMER "$homer_no\t$c1\t$pos1\t$strand1\t$c1\t$pos2\t$strand2\n";
    $homer_no++;

    # GOTHiC: two lines per pair
    my $gfh = $gfh{$chr1};
    print $gfh "$name\t$str1\t$c1\t$pos1\n";
    print $gfh "$name\t$str2\t$c1\t$pos2\n";

    $written++;
}
close IN;
close HOMER;
for my $c (1..22, "X", "Y") { close $gfh{$c}; }

print STDERR "Done. Total: $total pairs | Written (cis MAPQ>=30): $written\n";
