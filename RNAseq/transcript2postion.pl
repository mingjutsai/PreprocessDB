#!/usr/bin/perl
use strict;
use warnings;
my $abundance = $ARGV[0];
my $genefile = $ARGV[1];
if(@ARGV < 1){
    print STDERR "perl transcript2position.pl abundance.tsv genefile\n";die;
}
my $match_no = 0;
my $unmatch_no = 0;
my $output = $abundance."_ensembl99_annovar";
open OUT,">",$output;
#print OUT "#Chr\tStart\tEnd\tRef\tAlt\tGene\tTranscript\n";
open IN,"<",$abundance;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^target_id/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $est = $ele[3];
    if($est == 0){
        next;
    }
    my $tpm = $ele[4];
    my $transcript = $ele[0];
    my @tx = split(/\./,$transcript);
    my $txid = $tx[0];
    print STDERR $txid."\n";
    my $cmd = "grep ".$txid." ".$genefile;
    my $results = `$cmd`;
    $results =~ s/\n//;
    if(!$results){
        $unmatch_no++;
	next;
    }else{
        $match_no++;
    }
    #print STDERR $results."\n";
    my @tx_info = split(/\t/,$results);
    my $chr = $tx_info[2];
    if($chr =~ /chr\d+_\w+/){
        next;
    }
        my $start = $tx_info[4];
        my $end = $start;
        my $gene = $tx_info[12];
        my $type1 = $tx_info[13];
        my $type2 = $tx_info[14];
        if(($type1 eq "cmpl")and($type2 eq "cmpl")){
            my $info = join("\t",$chr,$start,$end,'A','T',$gene,$transcript,$est,$tpm);
	    print OUT $info."\n";
        }
    
}
close IN;
close OUT;

print STDERR "match:".$match_no."\nunmatch:".$unmatch_no."\n";
