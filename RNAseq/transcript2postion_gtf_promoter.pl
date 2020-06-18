#!/usr/bin/perl
use strict;
use warnings;
my $abundance = $ARGV[0];
my $gtf = $ARGV[1];
if(@ARGV < 1){
    print STDERR "perl transcript2position.pl transcript_list gtf\n";die;
}
#promoter range: -1000, +100 bp
my $match_no = 0;
my $unmatch_no = 0;
my $output = $abundance."_gtf_promoter";
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
    my $cmd = "grep ".$txid." ".$gtf;
    my $results = `$cmd`;
    $results =~ s/\n$//;
    if(!$results){
        $unmatch_no++;
	next;
    }else{
	    #print STDERR $results."\n";
        $match_no++;
    }
    #print STDERR $results."\n";
    my @tx_info = split(/\n/,$results);
    foreach my $i (@tx_info){
        my @each_tx = split(/\t/,$i);
        my $type = $each_tx[2];
	if($type eq "transcript"){
	    if($i =~ /gene_type "protein_coding"/){
		my $chr = $each_tx[0];
		if($chr =~ /chr\d+_\w+/){
		    next;
		}
	        my $start = $each_tx[3] - 1;
		my $end = $start;
		my $gene_info = $each_tx[8];
		my $info = join("\t",$chr,$start,$end,'A','T',$gene_info,$est,$tpm);
		print OUT $info."\n";
	    }
	}
    }
    
}
close IN;
close OUT;

print STDERR "match:".$match_no."\nunmatch:".$unmatch_no."\n";
