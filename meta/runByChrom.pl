#!/usr/bin/perl
use strict;
use warnings;
my $type = $ARGV[0];
if(($type ne "FNBMD")and($type ne "LSBMD")){
    print STDERR "type is error\n";die;
}
#transfer meta format to annovar
#sort annovar
#split by chr
my $header = "header_TOPMedFreeze8_UK10K_meta_".$type.".txt_filter_annovar";
if(!-e $header){
    print STDERR "header is not exist\n";die;
}
my $merge_fuma_cmd = "cat ";
for(my $i=1;$i<=23;$i++){
    if($i == 23){
        $i = 'X';
    }elsif($i == 24){
        $i = 'Y';
    }
    print STDERR "step0:sorting\n";
    my $sorted =  "chr".$i."/TOPMedFreeze8_UK10K_meta_".$type.".txt_filter_annovar_trim_chr".$i."_sorted";
    my $cmd = "bash ~/PreprocessDB/sortedBed.sh chr".$i."/TOPMedFreeze8_UK10K_meta_".$type.".txt_filter_annovar_trim_chr".$i." ".$sorted;
    print STDERR $cmd."\n";
    `$cmd`;
    if(!-e $sorted){
        print STDERR "sorted is not exist\n";die;
    }
    print STDERR "step1:add header\n";
    my $withHeader = "chr".$i."/TOPMedFreeze8_UK10K_meta_".$type.".txt_filter_annovar_trim_chr".$i."_sorted_withHeader";
    $cmd = "cat ".$header." ".$sorted." > ".$withHeader;
    print STDERR $cmd."\n";
    `$cmd`;
    if(!-e $withHeader){
        print STDERR "withHeader is not exist\n";die;
    }
    print STDERR "step2:correct ref\n";
    my $correctRef = $withHeader."_correctRed";
    $cmd = "~/PreprocessDB/retrieve_seq_from_fasta.pl --format tab -seqdir ~/CrossMap/chain/GRCh38/ --tabout --outfile ".$correctRef." ".$withHeader;
    print STDERR $cmd."\n";
    `$cmd`;
    if(!-e $correctRef){
        print STDERR "correctRef is not exist\n";die;
    }
    print STDERR "step3:hg38 To hg19\n";
    my $hg19vcf = $correctRef."_hg38Tohg19.vcf";
    $cmd = "python3 ~/CrossMap/bin/CrossMap.py vcf ~/CrossMap/chain/UCSC_chain/hg38ToHg19.over.chain ".$correctRef." ~/CrossMap/chain/hg19/hg19.fa ".$hg19vcf;
    print STDERR $cmd."\n";
    `$cmd`;
    if(!-e $hg19vcf){
        print STDERR "hg19vcf is not exist\n";die;
    }
    print STDERR "step4:filter chrome\n";
    $cmd = "perl ~/PreprocessDB/meta/Chr_filter.pl ".$hg19vcf." ".$i;
    print STDERR $cmd."\n";
    `$cmd`;
    if($i eq 'X'){
        $i = 23;
    }elsif($i eq 'Y'){
        $i = 24;
    }
    my $chr_mapped = $hg19vcf.".Chr_mapped";
    if(!-e $chr_mapped){
        print STDERR "Chr mapped is not exist\n";die;
    }
    print STDERR "step5:transfer2fuma\n";
    my $vcffilter = "chr".$i."/TOPMedFreeze8_UK10K_meta_FNBMD.txt_annovar_trim_chr".$i."_sorted_withHeader_correctRed_hg38Tohg19.vcf.filter";
    my $fuma = $chr_mapped."_fuma";
    if($i eq '1'){
        $cmd = "cat ".$chr_mapped." | cut -f 1,2,16,22 > ".$fuma;
    }else{
        $cmd = "tail -n+2 ".$chr_mapped." | cut -f 1,2,16,22 > ".$fuma;
    }
    print STDERR $cmd."\n";
    `$cmd`;
    $merge_fuma_cmd .= $fuma." ";
    if($i eq 'X'){
        $i = 23;
    }elsif($i eq 'Y'){
        $i = 24;
    }
}
my $merge_fuma = "TOPMedFreeze8_UK10K_meta_".$type."_fuma_merge.txt";
$merge_fuma_cmd .= "> ".$merge_fuma;
print STDERR $merge_fuma_cmd."\n";
`$merge_fuma_cmd`;
#fuma header must be Chr
