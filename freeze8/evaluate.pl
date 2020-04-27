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
if(@ARGV < 1){
    print STDERR "perl evaluate.pl annotation\n";die;
}
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

my $primate_tp=0;
my $primate_tn=0;
my $primate_fp=0;
my $primate_fn=0;

my $clinvar_tp=0;
my $clinvar_tn=0;
open IN,"<",$input;
my $line;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $svm = $ele[6];
    my $lr = $ele[7];
    my $cadd = $ele[8];
    my $revel = $ele[9];
    my $clinvar = $ele[12];
    my $primate = $ele[10];
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
        }else{
            $svm_undefined++;
        }
        #metaLR
        if($lr eq 'T'){
            $lr_tn++;
	    $T_no++;
        }elsif($lr eq 'D'){
            $lr_fp++;
	    $D_no++;
        }else{
            $lr_undefined++;
        }
        #CADD
        if($cadd eq 'T'){
            $cadd_tn++;
	    $T_no++;
        }elsif($cadd eq 'D'){
            $cadd_fp++;
	    $D_no++;
        }else{
            $cadd_undefined++;
        }
        #REVEL
        if($revel eq 'T'){
            $revel_tn++;
	    $T_no++;
        }elsif($revel eq 'D'){
            $revel_fp++;
	    $D_no++;
        }else{
            $revel_undefined++;
        }
	if($primate eq 'T'){
	   $primate_tn++;
	   $T_no++;
	}elsif($primate eq 'D'){
	   $primate_fp++;
	   $D_no++;
	}
        #OR
        if(($svm eq 'D')or($lr eq 'D')or($cadd eq 'D')or($revel eq 'D')or($primate eq 'D')){
            $or_fp++;
        }elsif(($svm eq '.')and($lr eq '.')and($cadd eq '.')and($revel eq '.')){
            $or_undefined++;
        }else{
	    $or_tn++;
	}
        #ADD
        if(($svm eq 'T')and($lr eq 'T')and($cadd eq 'T')and($revel eq 'T')and($primate eq 'T')){
            $add_tn++;
        }elsif(($svm eq 'D')and($lr eq 'D')and($cadd eq 'D')and($revel eq 'D')and($primate eq 'D')){
            $add_fp++;
        }else{
            $add_undefined++;
        }
	#VOTE
	if($D_no >= 3){
	    $vote_fp++;
	}elsif($T_no >= 3){
	    $vote_tn++;
	}
    }else{#TP
        $clinvar_tp++;
        #metasvm
        if($svm eq 'T'){
            $svm_fn++;
	    $T_no++;
        }elsif($svm eq 'D'){
            $svm_tp++;
	    $D_no++;
        }else{
            $svm_undefined++;
        }
        #metaLR
        if($lr eq 'T'){
            $lr_fn++;
	    $T_no++;
        }elsif($lr eq 'D'){
            $lr_tp++;
	    $D_no++
        }else{
            $lr_undefined++;
        }
        #CADD
        if($cadd eq 'T'){
            $cadd_fn++;
	    $T_no++;
        }elsif($cadd eq 'D'){
            $cadd_tp++;
	    $D_no++;
        }else{
            $cadd_undefined++;
        }
        #REVEL
        if($revel eq 'T'){
            $revel_fn++;
	    $T_no++;
        }elsif($revel eq 'D'){
            $revel_tp++;
	    $D_no++;
        }else{
            $revel_undefined++;
        }
	#Primate
	if($primate eq 'T'){
	    $primate_fn++;
	    $T_no++;
	}elsif($primate eq 'D'){
	    $primate_tp++;
	    $D_no++;
	}
        #OR
        if(($svm eq 'D')or($lr eq 'D')or($cadd eq 'D')or($revel eq 'D')or($primate eq 'D')){
            $or_tp++;
        }elsif(($svm eq '.')and($lr eq '.')and($cadd eq '.')and($revel eq '.')and($primate eq '.')){
	    $or_undefined++;
	}
	else{
            $or_fn++;
        }
        #ADD
        if(($svm eq 'T')and($lr eq 'T')and($cadd eq 'T')and($revel eq 'T')and($primate eq 'T')){
            $add_fn++;
        }elsif(($svm eq 'D')and($lr eq 'D')and($cadd eq 'D')and($revel eq 'D')and($primate eq 'D')){
            $add_tp++;
        }else{
            $add_undefined++;
        }
	#vote
	if($T_no >= 3){
	    $vote_fn++;
	}elsif($D_no >= 3){
	    $vote_tp++;
	}
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
my ($primate_sen,$primate_spe,$primate_acc,$primate_cov,$primate_mcc) = performance($primate_tp,$primate_tn,$primate_fp,$primate_fn,$clinvar_total);

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

print STDERR "====MetaLR====\n";
print_performance($lr_sen,$lr_spe,$lr_acc,$lr_cov,$lr_mcc);

print STDERR "====CADD====\n";
print_performance($cadd_sen,$cadd_spe,$cadd_acc,$cadd_cov,$cadd_mcc);

print STDERR "====REVEL====\n";
print_performance($revel_sen,$revel_spe,$revel_acc,$revel_cov,$revel_mcc);

print STDERR "===VEST4===\n";
print_performance($primate_sen,$primate_spe,$primate_acc,$primate_cov,$primate_mcc);

print STDERR "====ADD====\n";
print_performance($add_sen,$add_spe,$add_acc,$add_cov,$add_mcc);

print STDERR "====OR====\n";
print_performance($or_sen,$or_spe,$or_acc,$or_cov,$or_mcc);

print STDERR "====VOTE====\n";
print_performance($vote_sen,$vote_spe,$vote_acc,$vote_cov,$vote_mcc);
