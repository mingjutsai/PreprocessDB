#!/usr/bin/perl
use strict;
use warnings;
sub performance {
    my ($TP, $TN, $FP, $FN, $cln_total) = @_;
    my $Sen = $TP/($TP + $FN);
    my $Spe = $TN/($TN + $FP);
    my $total = $TP + $TN + $FN + $FP;
    my $Acc = ($TP + $TN)/$total;
    my $coverage = $total/$cln_total;
    my $Mcc = ($TP*$TN - $FP*$FN)/sqrt(($TP + $FP)*($TP + $FN)*($TN + $FP)*($TN + $FN));
    print STDERR "TP:".$TP."\tTN:".$TN."\tFP:".$FP."\tFN:".$FN."\n";
    return ($Sen, $Spe, $Acc, $coverage, $Mcc);
}

sub print_performance {
    my ($sen,$spe,$acc,$cov,$mcc) = @_;
    print STDERR "Sen:".$sen."\n";
    print STDERR "Spe:".$spe."\n";
    print STDERR "Acc:".$acc."\n";
    print STDERR "Cov:".$cov."\n";
    print STDERR "Mcc:".$mcc."\n";
}
my $input = $ARGV[0];
my $threshold = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl evaluate.pl annotation threshold_file\n";die;
}
my %cutoff;
open THR,"<",$threshold;
while(my $line=<THR>){
    chomp $line;
    my @ele = split(/\t/,$line);
    $cutoff{$ele[0]} = $ele[1];
}
close THR;

my %sig;
my $svm_tp=0;
my $svm_tn=0;
my $svm_fp=0;
my $svm_fn=0;
my $svm_undefined=0;

my $lr_tp=0;
my $lr_tn=0;
my $lr_fp=0;
my $lr_fn=0;
my $lr_undefined=0;

my $cadd_tp=0;
my $cadd_tn=0;
my $cadd_fp=0;
my $cadd_fn=0;
my $cadd_undefined=0;

my $revel_tp=0;
my $revel_tn=0;
my $revel_fp=0;
my $revel_fn=0;
my $revel_undefined=0;

my $vest_tp=0;
my $vest_tn=0;
my $vest_fp=0;
my $vest_fn=0;
my $vest_undefined=0;

my $add_tp=0;
my $add_tn=0;
my $add_fp=0;
my $add_fn=0;
my $add_undefined=0;

my $or_tp=0;
my $or_tn=0;
my $or_fp=0;
my $or_fn=0;
my $or_undefined=0;

my $vote_tp=0;
my $vote_tn=0;
my $vote_fp=0;
my $vote_fn=0;
my $vote_undefined=0;

my $variant_no=0;
my $clinvar_tp=0;
my $clinvar_tn=0;

my %score_confidence;
open IN,"<",$input;
while(my $line=<IN>){
    if($line =~ /^#/){
        next;
    }
    chomp $line;
    $variant_no++;
    my @ele = split(/\t/,$line);
    my $cadd_score = $ele[6];
    my $svm_score = $ele[7];
    my $lr_score = $ele[8];
    my $vest_score = $ele[9];
    my $revel_score = $ele[10];

    #print STDERR "CADD:".$cadd_score."\tSVM:".$svm_score."\tLR:".$lr_score."\tVEST:".$vest_score."\tREVEL:".$revel_score."\n";

    my $svm;
    my $lr;
    my $cadd;
    my $revel;
    my $vest;
    my $each_D_no=0;
    my $each_T_no=0;
    if(($svm_score eq '.')or($svm_score eq 'NA')){
        $svm = 'NA';
	$svm_undefined++;
    }
    elsif($svm_score >= $cutoff{'MetaSVM'}){
       $svm = 'D';
       $each_D_no++;
    }else{
       $svm = 'T';
       $each_T_no++;
    }

   if(($lr_score eq '.')or($lr_score eq 'NA')){
      $lr = 'NA';
      $lr_undefined++;
   }
   elsif($lr_score >= $cutoff{'MetaLR'}){
       $lr = 'D';
       $each_D_no++;
   }else{
       $lr = 'T';
       $each_T_no++;
   }

   if(($vest_score eq '.')or($vest_score eq 'NA')){
       $vest = "NA";
       $vest_undefined++;
   }
   elsif($vest_score >= $cutoff{'VEST'}){
       $vest = 'D';
       $each_D_no++;
   }else{
       $vest = 'T';
       $each_T_no++;
   }

   #print STDERR "VEST:".$vest_score."\n";
   if(($cadd_score eq '.')or($cadd_score eq 'NA')){
       $cadd = "NA";
       $cadd_undefined++;
   }
   elsif($cadd_score >= $cutoff{'CADD'}){
       $cadd = 'D';
       $each_D_no++;
   }else{
       $cadd = 'T';
       $each_T_no++;
   }

   if(($revel_score eq '.')or($revel_score eq 'NA')){
       $revel = "NA";
       $revel_undefined++;
   }
   elsif($revel_score >= $cutoff{'REVEL'}){
       $revel = 'D';
       $each_D_no++;
   }else{
       $revel = 'T';
       $each_T_no++;
   }
   if($each_D_no > $each_T_no){
       $score_confidence{$each_D_no}++;
   }elsif($each_T_no > $each_D_no){
       $score_confidence{$each_T_no}++;
   }else{
       $vote_undefined++;
   }

    my $clinvar = $ele[11];
    my $ans;
    my $D_no=0;
    my $T_no=0;
    if(($clinvar eq "Pathogenic/Likely_pathogenic")or($clinvar eq "Pathogenic")or($clinvar eq "Likely_pathogenic")or($clinvar eq "Pathogenic,_risk_factor")or($clinvar eq "Pathogenic/Likely_pathogenic,_other")or($clinvar eq "Pathogenic,_other")or($clinvar eq "Likely_pathogenic,_risk_factor")){
        $ans = 'TP';
    }elsif(($clinvar eq "Benign/Likely_benign")or($clinvar eq "Likely_benign")or($clinvar eq "Benign/Likely_benign,_other")or($clinvar eq "Benign")or($clinvar eq "Likely_benign,_other")){
        $ans = 'TN';
    }else{
        next;
    }
    #print STDERR $ans."\n";
    if($ans eq 'TN'){
        $clinvar_tn++;
        #metasvm
        if($svm eq 'T'){
            $svm_tn++;
	    $T_no++;
        }elsif($svm eq 'D'){
            $svm_fp++;
	    $D_no++;
        }
  
        #metaLR
        if($lr eq 'T'){
            $lr_tn++;
	    $T_no++;
        }elsif($lr eq 'D'){
            $lr_fp++;
	    $D_no++;
        }

        #CADD
        if($cadd eq 'T'){
            $cadd_tn++;
	    $T_no++;
        }elsif($cadd eq 'D'){
            $cadd_fp++;
	    $D_no++;
        }

        #REVEL
        if($revel eq 'T'){
            $revel_tn++;
	    $T_no++;
        }elsif($revel eq 'D'){
            $revel_fp++;
	    $D_no++;
        }

	#VEST
	if($vest eq 'T'){
	    $vest_tn++;
	    $T_no++;
	}elsif($vest eq 'D'){
	    $vest_fp++;
	    $D_no++;
	}
        #OR
        if(($svm eq 'D')or($lr eq 'D')or($cadd eq 'D')or($revel eq 'D')or($vest eq 'D')){
            $or_fp++;
        }elsif(($svm eq 'NA')and($lr eq 'NA')and($cadd eq 'NA')and($revel eq 'NA')and($vest eq 'NA')){
		#$or_undefined++;
        }else{
	    $or_tn++;
	}
        #ADD
	if(($D_no > 0)and($T_no == 0)){
	    $add_fp++;
	}elsif(($T_no > 0)and($D_no == 0)){
	    $add_tn++;
	}
	#if(($svm eq 'T')and($lr eq 'T')and($cadd eq 'T')and($revel eq 'T')and($primate eq 'T')){
	#    $add_tn++;
	#}elsif(($svm eq 'D')and($lr eq 'D')and($cadd eq 'D')and($revel eq 'D')and($primate eq 'D')){
	#    $add_fp++;
	#}else{
	#    $add_undefined++;
	#}
	#VOTE
	if($D_no > $T_no){
	    $vote_fp++;
	}elsif($T_no > $D_no){
	    $vote_tn++;
	}
	#if($D_no >= 3){
	#    $vote_fp++;
	#}elsif($T_no >= 3){
	#    $vote_tn++;
	#}
    }else{#TP
        $clinvar_tp++;
        #metasvm
        if($svm eq 'T'){
            $svm_fn++;
	    $T_no++;
        }elsif($svm eq 'D'){
            $svm_tp++;
	    $D_no++;
        }

        #metaLR
        if($lr eq 'T'){
            $lr_fn++;
	    $T_no++;
        }elsif($lr eq 'D'){
            $lr_tp++;
	    $D_no++
        }

        #CADD
        if($cadd eq 'T'){
            $cadd_fn++;
	    $T_no++;
        }elsif($cadd eq 'D'){
            $cadd_tp++;
	    $D_no++;
        }

        #REVEL
        if($revel eq 'T'){
            $revel_fn++;
	    $T_no++;
        }elsif($revel eq 'D'){
            $revel_tp++;
	    $D_no++;
        }

	#VEST
	if($vest eq 'T'){
	    $vest_fn++;
	    $T_no++;
	}elsif($vest eq 'D'){
	    $vest_tp++;
	    $D_no++;
	}
        #OR
        if(($svm eq 'D')or($lr eq 'D')or($cadd eq 'D')or($revel eq 'D')or($vest eq 'D')){
            $or_tp++;
        }elsif(($svm eq 'NA')and($lr eq 'NA')and($cadd eq 'NA')and($revel eq 'NA')and($vest eq 'NA')){
		#$or_undefined++;
	}
	else{
            $or_fn++;
        }
        #ADD
	if(($T_no > 0)and($D_no == 0)){
	    $add_fn++;
	}elsif(($D_no > 0)and($T_no == 0)){
	    $add_tp++;
	}
	#if(($svm eq 'T')and($lr eq 'T')and($cadd eq 'T')and($revel eq 'T')and($primate eq 'T')){
	#    $add_fn++;
	#}elsif(($svm eq 'D')and($lr eq 'D')and($cadd eq 'D')and($revel eq 'D')and($primate eq 'D')){
	#    $add_tp++;
	#}else{
	#    $add_undefined++;
	#}
	#vote
	if($T_no > $D_no){
	    $vote_fn++;
	}elsif($D_no > $T_no){
	    $vote_tp++;
	}
	#if($T_no >= 3){
	#    $vote_fn++;
	#}elsif($D_no >= 3){
	#    $vote_tp++;
	#}
    }
}
close IN;
my $clinvar_total = $clinvar_tn+$clinvar_tp;
print STDERR "====MetaSVM====\n";
my ($svm_sen,$svm_spe,$svm_acc,$svm_cov,$svm_mcc) = performance($svm_tp,$svm_tn,$svm_fp,$svm_fn,$clinvar_total); 

print STDERR "====MetaLR====\n";
my ($lr_sen,$lr_spe,$lr_acc,$lr_cov,$lr_mcc) = performance($lr_tp,$lr_tn,$lr_fp,$lr_fn, $clinvar_total);

print STDERR "===CADD===\n";
my ($cadd_sen,$cadd_spe,$cadd_acc,$cadd_cov,$cadd_mcc) = performance($cadd_tp,$cadd_tn,$cadd_fp,$cadd_fn,$clinvar_total);

print STDERR "===REVEL===\n";
my ($revel_sen,$revel_spe,$revel_acc,$revel_cov,$revel_mcc) = performance($revel_tp,$revel_tn,$revel_fp,$revel_fn,$clinvar_total);


print STDERR "===VEST4===\n";
my ($vest_sen,$vest_spe,$vest_acc,$vest_cov,$vest_mcc) = performance($vest_tp,$vest_tn,$vest_fp,$vest_fn,$clinvar_total);

print STDERR "====OR====\n";
my ($or_sen,$or_spe,$or_acc,$or_cov,$or_mcc) = performance($or_tp,$or_tn,$or_fp,$or_fn,$clinvar_total);

print STDERR "===ADD===\n";
my ($add_sen,$add_spe,$add_acc,$add_cov,$add_mcc) = performance($add_tp,$add_tn,$add_fp,$add_fn,$clinvar_total);

print STDERR "===VOTE===\n";
my ($vote_sen,$vote_spe,$vote_acc,$vote_cov,$vote_mcc) = performance($vote_tp,$vote_tn,$vote_fp,$vote_fn,$clinvar_total);

print STDERR "P:".$clinvar_tp."\n";
print STDERR "N:".$clinvar_tn."\n";
print STDERR "====MetaSVM====\n";
print_performance($svm_sen,$svm_spe,$svm_acc,$svm_cov,$svm_mcc);
my $all_svm_cov = ($variant_no - $svm_undefined)/$variant_no;
print STDERR "All Cov:".$all_svm_cov."\n";

print STDERR "====MetaLR====\n";
print_performance($lr_sen,$lr_spe,$lr_acc,$lr_cov,$lr_mcc);
my $all_lr_cov = ($variant_no - $lr_undefined)/$variant_no;
print STDERR "All Cov:".$all_lr_cov."\n";

print STDERR "====CADD====\n";
print_performance($cadd_sen,$cadd_spe,$cadd_acc,$cadd_cov,$cadd_mcc);
my $all_cadd_cov = ($variant_no - $cadd_undefined)/$variant_no;
print STDERR "All Cov:".$all_cadd_cov."\n";

print STDERR "====REVEL====\n";
print_performance($revel_sen,$revel_spe,$revel_acc,$revel_cov,$revel_mcc);
my $all_revel_cov = ($variant_no - $revel_undefined)/$variant_no;
print STDERR "All Cov:".$all_revel_cov."\n";

print STDERR "===VEST4===\n";
print_performance($vest_sen,$vest_spe,$vest_acc,$vest_cov,$vest_mcc);
my $all_vest_cov = ($variant_no - $vest_undefined)/$variant_no;
print STDERR "All Cov:".$all_vest_cov."\n";


print STDERR "====ADD====\n";
print_performance($add_sen,$add_spe,$add_acc,$add_cov,$add_mcc);

print STDERR "====OR====\n";
print_performance($or_sen,$or_spe,$or_acc,$or_cov,$or_mcc);

print STDERR "====VOTE====\n";
print_performance($vote_sen,$vote_spe,$vote_acc,$vote_cov,$vote_mcc);
my $all_vote_cov = ($variant_no - $vote_undefined)/$variant_no;
print STDERR "All Cov:".$all_vote_cov."\n";

print STDERR "VOTE distribution\n";
my @key = keys %score_confidence;
foreach my $i (@key){
    print STDERR $i.":".$score_confidence{$i}."\n";
}
print STDERR "Total variant:".$variant_no."\n";
