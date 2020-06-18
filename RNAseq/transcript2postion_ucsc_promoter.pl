#!/usr/bin/perl
use strict;
use warnings;
my $abundance = $ARGV[0];
my $ucsc = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl transcript2position.pl transcript_list ucsc_format\n";die;
}
my $coding_no = 0;
my %ucsc;
my %ucsc_ctss;
open UCSC,"<",$ucsc;
while(my $line=<UCSC>){
    chomp $line;
    my @tx_info = split(/\t/,$line);
    my $state1 = $tx_info[13];
    my $state2 = $tx_info[14];
    if(($state1 eq "cmpl")and($state2 eq "cmpl")){
        my $chr = $tx_info[2];
        if($chr =~ /chr\d+_\w+/){
            next;
        }
        my $tss = $tx_info[4];
        my $gene = $tx_info[12];
        my $start = $tss - 1000;
        my $end = $tss + 100;
        if($start < 0){
            next;
        }
        my $tx_info = "TxStart:".$chr."-".$tss.",Promoter:".$chr."-".$start."-".$end.",Gene:".$gene;
        my $info = join("\t",$chr,$start,$end,$tx_info);
	my $ctss_info = join("\t",$chr,$tss,$tss,"A","T",);
        my $transcript = $tx_info[1];
        my @tx = split(/\./,$transcript);
        my $txid = $tx[0];
	$ucsc{$txid} = $tx_info;
	$ucsc_ctss{$txid} = $ctss_info;
	$coding_no++;
    }
}
close UCSC;
print STDERR "Load ".$coding_no." protein coding genes\n";
#promoter range: -1000, +100 bp
my $match_no = 0;
my $unmatch_no = 0;
my $output = $abundance."_ucsc_promoter";
my $ctss = $abundance."_ucsc_ctss";
open CTSS,">",$ctss;
print CTSS "#Chr\tStart\tEnd\tRef\tAlt\tTranscriptID\tEST\tTPM\n";
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
    #print STDERR $txid."\n";
    if($ucsc{$txid}){
	my @tx = split(/,/,$ucsc{$txid});
	#print STDERR $tx[1]."\n";
	my @promoter_info = split(/:/,$tx[1]);
	my ($chr,$start,$end) = split(/-/,$promoter_info[1]);
        print OUT $chr."\t".$start."\t".$end."\t".$ucsc{$txid}.",TxID:".$transcript.",EST:".$est.",TPM:".$tpm."\n";
	print CTSS $ucsc_ctss{$txid}."\t".$transcript."\t".$est."\t".$tpm."\n";;
	$match_no++;
    }
}
close IN;
close OUT;
close CTSS;
print STDERR "match:".$match_no."\n";
