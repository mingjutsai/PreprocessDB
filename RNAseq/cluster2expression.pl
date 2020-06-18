#!/usr/bin/perl
use strict;
use warnings;
my $cluster_list = $ARGV[0];
my $group_no = $ARGV[1];
my $expression = $ARGV[2];
my $ucsd_gene = $ARGV[3];
if(@ARGV < 4){
    print STDERR "perl cluster2expressionpl cluster_list group_id origin_expression ucsd_gene\n";
    print STDERR "promoter regiion -1000, TSS, 100 bp\n";die;
}
my $expression_no = 0;
my %expression;
open EX,"<",$expression;
while(my $line=<EX>){
    chomp $line;
    if($line =~ /^ENST/){
        my @ele = split(/\t/,$line);
	my $time_point = scalar @ele;
	my $id = $ele[0];
	my $ex_value;
	for(my $i=1;$i<$time_point;$i++){
	    $ex_value .= $ele[$i]."\t";
        }
	$ex_value =~ s/\t$//;
	#print STDERR $ex_value."\n";die;
	$expression{$id} = $ex_value;
	$expression_no++;
    }
}
close EX;
print STDERR "Load ".$expression_no." gene expression\n";

my %ucsdgene;
my $protein_coding_gene = 0;
open UCSD,"<",$ucsd_gene;
while(my $line=<UCSD>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my @id = split(/\./,$ele[1]);
    my $id = $id[0];
    my $chr = $ele[2];
    my $tss = $ele[4];
    my $start = $tss - 1000;
    if($start < 0){
        next;
    }
    my $end = $tss + 100;
    my $status1 = $ele[13];
    my $status2 = $ele[14];
    if(($status1 ne "cmpl")and($status2 ne "cmpl")){
        next;
    }
    my $gene = $ele[12];
    my $info = join("\t",$chr,$start,$end,$gene);
    #print STDERR $id."\n";die;
    $ucsdgene{$id} = $info;
    $protein_coding_gene++;
}
close UCSD;
print STDERR "Load ".$protein_coding_gene." protein coding gene\n";

my $match_no = 0;
my $output = $cluster_list."_cluster".$group_no.".txt";
open OUT,">",$output;
open LIST,"<",$cluster_list;
my $line=<LIST>;
while($line=<LIST>){
    chomp $line;
    if($line =~ /Genes/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $id = $ele[$group_no];
    if(!$id){
        last;
    }
    if(!$expression{$id}){
        next;
    }
    if(!$ucsdgene{$id}){
        next;
    }
    print OUT $ucsdgene{$id}."\t".$id."\t".$expression{$id}."\n";
    $match_no++;
}
close LIST;
print STDERR "Match ".$match_no." transcript expression\n";
