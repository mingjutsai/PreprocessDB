#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $hic_index = $ARGV[1];
my $header_name = $ARGV[2];
if(@ARGV < 3){
    print STDERR "perl hic_target_gene.pl input hic_index hdeader_name\n";die;
}
my $output = $input."_".$header_name;
open OUT,">",$output;
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        print OUT $line."\t".$header_name."\n";next;
    }
    my $target_genes;
    my @ele = split(/\t/,$line);
    my $hic = $ele[$hic_index];
    if($hic eq "NA"){
        print OUT $line."\tNA\n";
    }else{
        if($hic =~ /;/){
            my @hic = split(/;/,$hic);
            foreach my $i (@hic){
                my @each_hic = split(/,/,$i);
                foreach my $j (@each_hic){
                    if($j =~ /TargetGene:/){
                       #print $j."\n";die;
                       my @gene = split(/:/,$j);
                       if(!$target_genes){
                           $target_genes .= $gene[1].","
                       }elsif($target_genes !~ /$gene[1]/){
                           $target_genes .= $gene[1]."," 
                       }
                       
                    }
                }
            }
            $target_genes =~ s/,$//;
            print OUT $line."\t".$target_genes."\n";
        }else{
            my @each_hic = split(/,/,$hic);
            foreach my $j (@each_hic){
                 if($j =~ /TargetGene:/){
                       my @gene = split(/:/,$j);
                       $target_genes .= $gene[1];
                 }
            }
            print OUT $line."\t".$target_genes."\n";
        }
    }
}
close IN;
close OUT;
