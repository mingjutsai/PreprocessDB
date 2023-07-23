#!/usr/bin/perl
use strict;
use warnings;
my $in = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl multiple_signal.pl input (GenomicRiskLoci.txt.annovar.fa.cond.results.txt)\n";die;
}
my %id;
my $uniq = $in.".uniq";
my $multi = $in.".multi";
open UNI,">",$uniq;
open MUL,">",$multi;
my $total_loci = 0;
my $orig_loci = 0;
my $rep = 0;
my %loci_multi;
open IN,"<",$in;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^Locus/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $loci = $ele[0];
    my $id = $ele[2];
    if($id ne "NA"){
        $id{$loci} = $id;
    }
    if($loci == $orig_loci){
        $rep++;
    }else{
	$total_loci++;
        $rep = 0;
    }
    if($rep == 1){
        print MUL $loci."\n";
	$loci_multi{$loci}++;
    }
    $orig_loci = $loci;
}

print "total loci:".$total_loci."\n";
for(my $i=1;$i<=$total_loci;$i++){
    if(!$loci_multi{$i}){
        print UNI $i."\t".$id{$i}."\n";
    }
}

close IN;
close MUL;
