#!/usr/bin/perl
use strict;
use warnings;
my $ucsc_gene = $ARGV[0];
my $clust_expression = $ARGV[1];
my $clust_list = $ARGV[2];
my $clust_group = $ARGV[3];
if(@ARGV < 4){
    print STDERR "perl clust2CodingGeneExpression.pl ucsc_gene gene_expression clust_list clust_id\n";die;
}
my $gene_no = 0;
my %gene;
open UCSC,"<",$ucsc_gene;
while(my $line=<UCSC>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $stat1 = $ele[13];
    my $stat2 = $ele[14];
    if(($stat1 ne "cmpl")and($stat2 ne "cmpl")){
        next;
    }
    my $gene = $ele[12];
    my $tss = $ele[4];
    my @tx = split(/\./,$ele[1]);
    my $tx_id = $tx[0];
    my $chr = $ele[2];
    my $start = $tss - 1000;
    if($start < 0){
        next;
    }
    my $end = $tss + 100;
    my $info = join("\t",$chr,$start,$end,$gene,$tss);
    $gene{$tx_id} = $info;
    $gene_no++;
    #print STDERR $tx_id."\t".$info."\n";die;
}
close UCSC;
print STDERR "Finish loading ".$gene_no." protein coding genes\n";

my $expression_no = 0;
my %expression;
open EX,"<",$clust_expression;
while(my $line=<EX>){
    chomp $line;
    if($line =~ /^ENST/){
        my @ele = split(/\t/,$line);
        my $point = scalar @ele;
        my $expression_value;
        for(my $i = 1;$i<$point;$i++){
            $expression_value .= $ele[$i]."\t";
        }
        $expression_value =~ s/\t$//;
        my $id = $ele[0];
        $expression{$id} = $expression_value;
        $expression_no++;
        #print STDERR $ele[0]."\t".$expression."\n";die;
    }
}
close EX;
print STDERR "Finish loading ".$expression_no." gene expression\n";

my $output = $clust_list."_Group".$clust_group.".txt";
open OUT,">",$output;
open LIST,"<",$clust_list;
while(my $line=<LIST>){
    chomp $line;
    if($line =~ /^ENST/){
        my @ele = split(/\t/,$line);
        my $id = $ele[$clust_group];
        if(!$id){
            last;
        }
        if($gene{$id} and $expression{$id}){
            print OUT $gene{$id}."\t".$id."\t".$expression{$id}."\n";
        }
    }

}
close LIST;