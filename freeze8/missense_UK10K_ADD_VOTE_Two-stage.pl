#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $threshold = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl missense_ADD_VOTE_Two-stage.pl input cutoff\n";die;
}
my %cutoff;
open THR,"<",$threshold;
while(my $line=<THR>){
    chomp $line;
    my @ele = split(/\t/,$line);
    $cutoff{$ele[0]} = $ele[1];
}
close THR;


my $overlap = 0;
my $svm_has_no = 0;
my $twostage_has_no = 0;
my $coding_filter1_no = 0;
my $coding_filter1_update_no = 0;

my $output = $input."_FinalScores";
my $damage = $input."_damage";
open DAMAGE,">",$damage;
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tADD\tVOTE\tCoding_Filter1\tTwo-Stage\tTwo-Stage-index\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my ($chr,$start,$end,$ref,$alt,$chr_hg19,$start_hg19,$ref_hg19,$alt_hg19,$gene) = ($ele[0],$ele[1],$ele[2],$ele[3],$ele[4],$ele[5],$ele[6],$ele[7],$ele[8],$ele[9]);
    #my $damage_info = join(",",$gene,$chr,$start,$ref,$alt);
    my $pos = join("\t",$chr,$start,$end,$ref,$alt);
    my $pos_hg19 = join("\t",$chr_hg19,$start_hg19,$ref_hg19,$alt_hg19);
    my $D_no = 0;
    my $T_no = 0;

    my $cadd_score = $ele[10];
    my $cadd;

    my $svm_score = $ele[11];
    my $svm;

    my $lr_score = $ele[12];
    my $lr;

    my $vest_score = $ele[13];
    my $vest;

    my $revel_score = $ele[14];
    my $revel;

    if(($svm_score eq '.')or($svm_score eq 'NA')){
        $svm = 'NA';
    }
    elsif($svm_score >= $cutoff{'MetaSVM'}){
       $svm = 'D';
       $D_no++;
    }else{
       $svm = 'T';
       $T_no++;
    }

   if(($lr_score eq '.')or($lr_score eq 'NA')){
      $lr = 'NA';
   }
   elsif($lr_score >= $cutoff{'MetaLR'}){
       $lr = 'D';
       $D_no++;
   }else{
       $lr = 'T';
       $T_no++;
   }

   if(($vest_score eq '.')or($vest_score eq 'NA')){
       $vest = "NA";
   }
   elsif($vest_score >= $cutoff{'VEST'}){
       $vest = 'D';
       $D_no++;
   }else{
       $vest = 'T';
       $T_no++;
   }

   #print STDERR "VEST:".$vest_score."\n";
   if(($cadd_score eq '.')or($cadd_score eq 'NA')){
       $cadd = "NA";
   }
   elsif($cadd_score >= $cutoff{'CADD'}){
       $cadd = 'D';
       $D_no++;
   }else{
       $cadd = 'T';
       $T_no++;
   }

   if(($revel_score eq '.')or($revel_score eq 'NA')){
       $revel = "NA";
   }
   elsif($revel_score >= $cutoff{'REVEL'}){
       $revel = 'D';
       $D_no++;
   }else{
       $revel = 'T';
       $T_no++;
   }
   my $two_step_index = 'NA';
   my $add = 'NA';
   my $vote = 'NA';
   my $two_step = 'NA';
   #ADD
   if(($D_no > 0)and($T_no == 0)){
       $two_step_index = "ADD";
       $add = 'D';
       $two_step = 'D';
   }elsif(($T_no > 0)and($D_no == 0)){
       $two_step_index = "ADD";
       $add = 'T';
       $two_step = 'T';
   }

   if($add eq 'NA'){
       #VOTE
       if($D_no > $T_no){
           $two_step_index = "VOTE,".$D_no;
	   $vote = 'D';
	   $two_step = 'D';
       }elsif($T_no > $D_no){
           $two_step_index = "VOTE,".$T_no;
	   $vote = 'T';
	   $two_step = 'T';
       }
   } 

   if(($svm eq 'D')and($two_step eq 'D')){
       $overlap++;
   }elsif(($svm ne 'D')and($two_step eq 'D')){
       $twostage_has_no++;
   }elsif(($svm eq 'D')and($two_step ne 'D')){
       $svm_has_no++;
   }
   if($svm eq 'D'){
       $coding_filter1_no++;
   }
   if($two_step eq 'D'){
       $coding_filter1_update_no++;
   }
   print OUT $pos."\t".$pos_hg19."\t".$add."\t".$vote."\t".$svm."\t".$two_step."\t".$two_step_index."\n";
   if($two_step eq 'D'){
       print DAMAGE $pos."\t".$pos_hg19."\t".$gene."\n";
   }
}
close IN;
close OUT;
close DAMAGE;

print STDERR "coding_filte1(missense):".$coding_filter1_no."\n";
print STDERR "coding_filter1_update(missense):".$coding_filter1_update_no."\n";
print STDERR "overlap no:".$overlap."\n";
print STDERR "only svm has:".$svm_has_no."\n";
print STDERR "only two-stage has:".$twostage_has_no."\n";
