#!/usr/bin/perl
use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;

# ------------------------------------------------------------
# This script extracts mRNA sequences from a reference FASTA
# based on a gene annotation file (e.g. ensGene, refGene).
#
# It is a wrapper around retrieve_seq_from_fasta.pl
#
# ------------------------------------------------------------

# Resolve script path
my $program = abs_path($0);
my $src_dir = dirname($program);
my $retrieve_seq = $src_dir . "/retrieve_seq_from_fasta.pl";

# Check dependency
if (!-e $retrieve_seq) {
    die "ERROR: retrieve_seq function <$retrieve_seq> does not exist\n";
}

# -----------------------
# Parse arguments
# -----------------------
if (@ARGV < 4) {
    print <<"USAGE";

Usage:
  perl $program <gene_file> <reference_seq_dir> <db_type> <genome_build>

Arguments:
  gene_file          Gene annotation file (e.g. BED / gene list)
  reference_seq_dir  Directory containing genome FASTA files
                     (e.g. hg19_reference_dir or hg38_reference_dir)
  db_type            Gene annotation database type:
                     ensGene | refGene | ccdsGene | knownGene | genericGene
  genome_build       Genome build version: 19 or 38

Example:
  perl $program genes.bed /data/genome/hg38 ensGene 38

Output:
  A FASTA file will be generated in the same directory as gene_file:
    hg<build>_<db_type>Mrna.fa

USAGE
    exit;
}

my ($genefile, $seq_path, $db, $build) = @ARGV;

# -----------------------
# Validate database type
# -----------------------
my %valid_db = map { $_ => 1 } qw(
    ensGene refGene ccdsGene knownGene genericGene
);

if (!exists $valid_db{$db}) {
    die "ERROR: Invalid db_type <$db>. Allowed values: "
        . join(", ", keys %valid_db) . "\n";
}

# -----------------------
# Build output path
# -----------------------
my $output_dir = dirname($genefile);
my $output = "$output_dir/hg${build}_${db}Mrna.fa";

# -----------------------
# Run sequence retrieval
# -----------------------
my $command = "perl $retrieve_seq "
            . "-format $db "
            . "-seqdir $seq_path "
            . "-outfile $output "
            . "$genefile";

print STDERR "Running command:\n$command\n";
system($command) == 0
    or die "ERROR: Failed to run retrieve_seq_from_fasta.pl\n";

