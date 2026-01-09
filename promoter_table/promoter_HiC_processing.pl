#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl promoter_table.pl promoter_overlap_HiC\n";die;
}
my $output = $input."_table.bed";
my $hic_bed = $input."_hic.bedpe";
open HIC,">",$hic_bed;
my %hic;
open OUT,">",$output;
print OUT "Chr\tStart\tEnd\tTranscript\tTSS\tGene\tStrand\tTranscript_support_level\tOpenChromatin\tChromHMM\tGeneTPM\tTranscriptTPM\tType\tScore\tScore_source\tHiC_Promoter_bin\tHiC_Distal_bin\tHiC_info\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $promoter_hic_id;
    my $distal_hic_id;
    my $hic_info;
    if($ele[18] eq '.'){
        $promoter_hic_id = 'NA';
	$distal_hic_id = 'NA';
	$hic_info = 'NA';
    }else{
        my @hic = split(/;/,$ele[18]);
        my @promoter = split(/:/,$hic[0]);
        $promoter_hic_id = join(":",$promoter[1],$promoter[2],$promoter[3]);
        #print STDERR "P:".$promoter_hic_id."\n";
        my @distal = split(/:/,$hic[1]);
        $distal_hic_id = join(":",$distal[1],$distal[2],$distal[3]);
        $hic_info = $hic[2];
	my $hic_interaction = "chr".$promoter[1]."\t".$promoter[2]."\t".$distal[2];
	my $hic_interaction_reverse = "chr".$promoter[1]."\t".$distal[2]."\t".$promoter[2];
	if(!$hic{$hic_interaction} and !$hic{$hic_interaction_reverse}){
	    print HIC $hic_interaction."\n";
	    $hic{$hic_interaction}++;
	    $hic{$hic_interaction_reverse}++;
	}
    }
    my $final;
    for(my $no=0;$no<=14;$no++){
	if($ele[$no] eq '.'){
	    $ele[$no] = 'NA';
	}
        $final .= $ele[$no]."\t";
    }
    $final .= $promoter_hic_id."\t".$distal_hic_id."\t".$hic_info;
    print OUT $final."\n";
}
close IN;
close OUT;
