#!/usr/bin/perl
# pre2homer_gothic.pl — Convert juicer .pre file to HOMER and GOTHiC formats
#                       in a single pass (avoids reading the large pre file twice)
#
# Input (.pre, 11 columns, sorted by chr1 then chr2):
#   readname str1 chr1 pos1 frag1  str2 chr2 pos2 frag2  mapq1 mapq2
#
# Outputs:
#   <homer_out>            — HOMER pairs format (7-col, all cis MAPQ>=30)
#   <gothic_dir>/<prefix>_chr{N}.gothic — GOTHiC per-chr format (2 lines/pair)
#
# HDD optimization: exploits the sorted order of .pre (sorted by chr1 then chr2).
# Cis pairs for each chromosome form a contiguous block, so GOTHiC files are
# written sequentially (one file open at a time), avoiding disk seeks.
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

open(my $homer_fh, ">", $homer_out) or die "Cannot open $homer_out: $!";
open(my $in_fh,   "<", $input)      or die "Cannot open $input: $!";

my $current_chr = "";
my $gfh;
my ($total, $written, $homer_no) = (0, 0, 1);

while (my $line = <$in_fh>) {
    chomp $line;
    # split with limit=12 avoids scanning beyond field 11
    my @e = split(/\t/, $line, 12);
    next if @e < 11;

    $total++;
    print STDERR "  ... $total pairs processed\n" if $total % 50_000_000 == 0;

    my ($name, $str1, $chr1, $pos1) = @e[0,1,2,3];
    my ($str2,        $chr2, $pos2) = @e[5,6,7];
    my ($mapq1, $mapq2)             = @e[9,10];

    next if $mapq1 < 30 || $mapq2 < 30;
    next if $chr1 ne $chr2;
    next unless $valid_chr{$chr1};

    # Exploit sorted order: cis pairs for each chromosome are contiguous.
    # Open a new GOTHiC file only when the chromosome changes.
    # This ensures each file is written sequentially (no interleaved seeks on HDD).
    if ($chr1 ne $current_chr) {
        close $gfh if defined $gfh;
        $current_chr = $chr1;
        my $fname = "$gothic_dir/${gothic_prefix}_chr${chr1}.gothic";
        open($gfh, ">", $fname) or die "Cannot open $fname: $!";
    }

    my $strand1 = ($str1 == 16) ? "-" : "+";
    my $strand2 = ($str2 == 16) ? "-" : "+";
    my $c = "chr$chr1";

    # HOMER: one line per pair
    print $homer_fh "$homer_no\t$c\t$pos1\t$strand1\t$c\t$pos2\t$strand2\n";
    $homer_no++;

    # GOTHiC: two lines per pair
    print $gfh "$name\t$str1\t$c\t$pos1\n";
    print $gfh "$name\t$str2\t$c\t$pos2\n";

    $written++;
}

close $in_fh;
close $homer_fh;
close $gfh if defined $gfh;

print STDERR "Done. Total: $total pairs | Written (cis MAPQ>=30): $written\n";
