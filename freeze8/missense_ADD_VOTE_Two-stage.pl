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

my $output = $input."_FinalScores";
my $damage = $input."_damage";
open DAMAGE,">",$damage;
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tADD\tVOTE\tTwo-Stage\tTwo-Stage-index\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my ($chr,$start,$end,$ref,$alt,$gene) = ($ele[0],$ele[1],$ele[2],$ele[3],$ele[4],$ele[5]);
    #my $damage_info = join(",",$gene,$chr,$start,$ref,$alt);
    my $pos = join("\t",$chr,$start,$end,$ref,$alt);
    my $D_no = 0;
    my $T_no = 0;

    my $cadd_score = $ele[6];
    my $cadd;

    my $svm_score = $ele[7];
    my $svm;

    my $lr_score = $ele[8];
    my $lr;

    my $vest_score = $ele[9];
    my $vest;

    my $revel_score = $ele[10];
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
   print OUT $pos."\t".$add."\t".$vote."\t".$two_step."\t".$two_step_index."\n";
   if($two_step eq 'D'){
       print DAMAGE $pos."\t".$gene."\n";
   }
}
close IN;
close OUT;
close DAMAGE;
