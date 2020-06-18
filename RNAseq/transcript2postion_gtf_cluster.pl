#!/usr/bin/perl
use strict;
use warnings;
my $abundance = $ARGV[0];
my $gtf = $ARGV[1];
if(@ARGV < 1){
    print STDERR "perl transcript2position.pl cluster gtf\n";die;
}
my $match_no = 0;
my $unmatch_no = 0;
my $output = $abundance."_gtf_annovar";
open OUT,">",$output;
#print OUT "#Chr\tStart\tEnd\tRef\tAlt\tGene\tTranscript\n";
open IN,"<",$abundance;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^cluster/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $cluster = $ele[0];
    my $txid = $ele[1];
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
	    my @info = split(/; /,$each_tx[8]);
	    my $gene_type = $info[2];
	    my $gene_name = $info[3];
	    $gene_type =~ s/"//g;
	    $gene_name =~ s/"//g;
	    my @type = split(/ /,$gene_type);
	    $gene_type = $type[1];
	    if($gene_type ne "protein_coding"){
	        next;
	    }
	    my @name = split(/ /,$gene_name);
	    $gene_name = $name[1];
	    #print STDERR "type:".$gene_type."\n";
	    #print STDERR "gene:".$gene_name."\n";
	    #die;
	    my $chr = $each_tx[0];
            if($chr =~ /chr\d+_\w+/){
		 next;
            }
	    my $start = $each_tx[3] - 1;
            my $gene_info = $each_tx[8];
	    my $info = join("\t",$chr,$start,$txid,$cluster,$gene_name);
            print OUT $info."\n";
	}
    }
}
close IN;
close OUT;

print STDERR "match:".$match_no."\nunmatch:".$unmatch_no."\n";
