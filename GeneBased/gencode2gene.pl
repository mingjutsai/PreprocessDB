#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl gencode2gene.pl gtf\n";die;
}
my $output = $input."_gene.txt";
my $fo;
open $fo,">",$output;
print $fo "#Chr\tStart\tEnd\tStrand\tGene_Name\tGene_ID\tGene_Type\n";
my $fh;
open $fh,"<",$input;
while(my $line=<$fh>){
    chomp $line;
    if($line =~ /^#/) {
        next;
    }
    my @ele = split(/\t/,$line);
    my $type = $ele[2];
    if($type ne 'gene'){
        next;
    }
    my $chr = $ele[0];
    my $start = $ele[3];
    my $end = $ele[4];
    my $strand = $ele[6];
    my $info = $ele[8];
    my $gene_name;
    my $gene_type;
    my $gene_id;
    my @info = split(/; /,$info);
    foreach my $i (@info){
	$i =~ s/"//g;
	#print STDERR $i."\n";
	my @gene = split(/ /,$i);
        if($gene[0] eq 'gene_name'){
	    $gene_name = $gene[1];
	}elsif($gene[0] eq 'gene_type'){
	    $gene_type = $gene[1];
	}elsif($gene[0] eq 'gene_id'){
	    $gene_id = $gene[1];
	}
    }
    my $final = join("\t",$chr,$start,$end,$strand,$gene_name,$gene_id,$gene_type);
    print $fo $final."\n";
}
close $fh;
close $fo;
