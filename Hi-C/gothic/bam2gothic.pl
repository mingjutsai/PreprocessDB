#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl bam2gothic.pl bam)\n";die;
}
my $old_id = "NA";
my $old_sam_flag = "NA";
my $old_chr = "NA";
my $old_pos = "NA";
my $old_mapq;
open(IN, "samtools view $input |");
while(my $line=<IN>){
    chomp $line;
    next if(substr($line,0,1) eq '@');    #Ignore headers

    my($id, $sam_flag, $chr, $position, $mapq) = split(/\t/, $line);
    if(($chr eq "chr1")or($chr eq "chr2")or($chr eq "chr3")or($chr eq "chr4")or($chr eq "chr5")or($chr eq "chr6")or($chr eq "chr7")or($chr eq "chr8")
     or($chr eq "chr9")or($chr eq "chr10")or($chr eq "chr11")or($chr eq "chr12")or($chr eq "chr13")or($chr eq "chr14")or($chr eq "chr15")
     or($chr eq "chr16")or($chr eq "chr17")or($chr eq "chr18")or($chr eq "chr19")or($chr eq "chr20")or($chr eq "chr21")or($chr eq "chr21")
     or($chr eq "chr22")or($chr eq "chrX")or($chr eq "chrY")or($chr eq "chrM")or($chr eq "chrMT")){
         if($id eq $old_id){
	     if($old_chr ne $chr){
	         next;
	     }
	     if($old_mapq < 30 or $mapq < 30){
	         next;
	     }
	     #if(!-d "splitChrom"){
	     #    my $cmd = "mkdir splitChrom";
	     # `$cmd`;
	     #}
	     my $output = $input.".".$chr.".gothic";
	     my $of;
	     open $of,">>",$output;
	     print $of "$old_id\t$old_sam_flag\t$old_chr\t$old_pos\n";
             print $of "$id\t$sam_flag\t$chr\t$position\n";
	     close $of;
        }
        $old_id = $id;
        $old_sam_flag = $sam_flag;
        $old_chr = $chr;
        $old_pos = $position;
	$old_mapq = $mapq;
    }
}
close IN;
