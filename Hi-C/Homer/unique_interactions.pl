#!/usr/bin/perl
use strict;
use warnings;
my $bed = $ARGV[0];
if(@ARGV < 1){
     print STDERR "perl unique_interactions.pl bed\n";die;
}
my %uniq;
open BED,"<",$bed;
while(my $line=<BED>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $interaction = $ele[6];
    my $gene = $ele[7];
    $gene =~ s/^Name=//;
    if (($interaction eq 'NA')or($gene eq 'NA')){
        next;
    }
    if($interaction =~ /,/){# multiple interactions
        my @inter = split(/,/,$interaction);
	foreach my $i (@inter){
	    $uniq{$i} = $gene; 
	}
    }else{# one interaction
        $uniq{$interaction} = $gene;
    }
}
close BED;

my $output = $bed."_uniq";
open OUT,">",$output;
my @uniq_inter = keys %uniq;
foreach my $i (@uniq_inter){
    print OUT $i."\t".$uniq{$i}."\n";
}
close OUT;
