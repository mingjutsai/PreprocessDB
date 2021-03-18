#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case);
use Cwd 'abs_path';
my $program = abs_path($0);
sub Usage {
        print STDERR "Usage: perl $program [Option]
        Option:
                -i  [FILE]
                -o_dir [DIR]
                -t   [STRING] snp, indel
                -h, --help      Show the usage\n
	ex: perl WGSA_extract_gz.pl.pl -i freeze.8.chrX.indel.annotation.general.first100000rows.txt.gz -o_dir ~/ -t indel
	    perl WGSA_extract_gz.pl.pl -i freeze.8.chrX.snp.annotation.general.first100000rows.txt.gz -o_dir ~/ -t snp\n";
}
my ($input, $o_dir, $type, $help);
GetOptions(
    'i=s' =>\ $input,
    'o_dir=s' =>\ $o_dir,
    't=s' =>\ $type,
    'help|h'        =>\ $help,
);
if(!$input || !$o_dir || !$type ||$help){
    Usage();
    die;
}
if(!-e $input){
    print STDERR $input." does not exist\n";die;
}
if($o_dir =~ /\/$/){
    $o_dir =~ s/\/$//;
}
if(($type ne "snp")and($type ne "indel")){
    print STDERR "type is error, must be snp or indel\n";die;
}
my $lof_hc = $o_dir."/".$input."_LoF_HC.txt";
my $inframe = $o_dir."/".$input."_inframe_indel.txt";
my $synonymous = $o_dir."/".$input."_synonymous.txt";
my $missense = $o_dir."/".$input."_missense.txt";
my $metasvm_damage = $o_dir."/".$input."_missense_MetaSVM_Damage.txt";
my $no = 0;
if($input =~ /\.gz$/){
    open(IN, "gunzip -c $input |") || die "can't open pipe to ".$input."\n";
}else{
    open IN,"<",$input;
}
my $line=<IN>;
chomp $line;
if($type eq "snp"){
    open SYN,">",$synonymous;
    print SYN "#Chr\tStart\tEnd\tRef\tAlt\tChr_hg19\tPos_hg19\tRef_hg19\tAlt_hg19\tGene\n";

    open HC,">",$lof_hc;
    print HC "#Chr\tStart\tEnd\tRef\tAlt\tChr_hg19\tPos_hg19\tRef_hg19\tAlt_hg19\tGene\n";

    open MIS,">",$missense;
    print MIS "#Chr\tStart\tEnd\tRef\tAlt\tChr_hg19\tPos_hg19\tRef_hg19\tAlt_hg19\tGene\n";

    open SVM,">",$metasvm_damage;
    print SVM "#Chr\tStart\tEnd\tRef\tAlt\tChr_hg19\tPos_hg19\tRef_hg19\tAlt_hg19\tGene\n";

}elsif($type eq "indel"){
   open INFRAME,">",$inframe;
   print INFRAME "#Chr\tStart\tEnd\tRef\tAlt\tChr_hg19\tPos_hg19\tRef_hg19\tAlt_hg19\tGene\n";

   open HC,">",$lof_hc;
   print HC "#Chr\tStart\tEnd\tRef\tAlt\tChr_hg19\tPos_hg19\tRef_hg19\tAlt_hg19\tGene\n";
}
my $VEP_ensembl_Consequence_no = 0;
my $VEP_ensembl_LoF_no = 0;
my $MetaSVM_pred_no = 0;
my $fathmmXF_pred_no = 0;
my $gene_id_no = 0;
my $chr_no = 0;
my $pos_no = 0;
my $ref_no = 0;
my $alt_no = 0;
my $chr_hg19_no = 0;
my $pos_hg19_no = 0;
my $ref_hg19_no = 0;
my $alt_hg19_no = 0;
#chr     pos     ref     alt     chr_hg19        pos_hg19        ref_hg19        alt_hg19
my @ele = split(/\t/,$line);
foreach my $i (@ele){
    if($i eq "VEP_ensembl_LoF"){
        $VEP_ensembl_LoF_no = $no;
    }elsif($i eq "VEP_ensembl_Consequence"){
        $VEP_ensembl_Consequence_no = $no;
    }elsif($i eq "MetaSVM_pred"){
        $MetaSVM_pred_no = $no;
    }elsif($i eq "VEP_ensembl_Gene_ID"){
        $gene_id_no = $no;
    }elsif($i eq "chr"){
        $chr_no = $no;
    }elsif($i eq "pos"){
        $pos_no = $no;
    }elsif($i eq "ref"){
        $ref_no = $no;
    }elsif($i eq "alt"){
        $alt_no = $no;
    }elsif($i eq "chr_hg19"){
        $chr_hg19_no = $no;
    }elsif($i eq "pos_hg19"){
        $pos_hg19_no = $no;
    }elsif($i eq "ref_hg19"){
        $ref_hg19_no = $no;
    }elsif($i eq "alt_hg19"){
        $alt_hg19_no = $no;
    }elsif($i eq "fathmm-XF_pred"){
        $fathmmXF_pred_no = $no;
    }
    $no++;
}
print STDERR "VEP_ensembl_Lof:".$VEP_ensembl_LoF_no."\tVEP_ensembl_Consequence:".$VEP_ensembl_Consequence_no."\tVEP_ensembl_Gene_ID:".$gene_id_no."\t";
print STDERR "MetaSVM_Pred:".$MetaSVM_pred_no."\tfathmm-XF_pred:".$fathmmXF_pred_no."\n";
while($line=<IN>){
    chomp $line;
    #print STDERR $line."\n";
    @ele = split(/\t/,$line);
    #print STDERR "VEP_ensembl_LoF:".$ele[$VEP_ensembl_LoF_no]."\nVEP_ensembl_Consequence:".$ele[$VEP_ensembl_Consequence_no]."\n";die;
    my $lof = $ele[$VEP_ensembl_LoF_no];
    my $vep_conseq = $ele[$VEP_ensembl_Consequence_no];
    my $metasvm_result = $ele[$MetaSVM_pred_no];
    my $fathmmXF_result = $ele[$fathmmXF_pred_no];
    my $chr = $ele[$chr_no];
    my $pos = $ele[$pos_no];
    my $ref = $ele[$ref_no];
    my $alt = $ele[$alt_no];
    my $end = $pos + length($ref) - 1;

    my $chr_hg19 = $ele[$chr_hg19_no];
    my $pos_hg19 = $ele[$pos_hg19_no];
    my $ref_hg19 = $ele[$ref_hg19_no];
    my $alt_hg19 = $ele[$alt_hg19_no];
    my @gene = split(/\|/,$ele[$gene_id_no]);
    my $gene_id = $gene[0];
    my $info = join("\t",$chr,$pos,$end,$ref,$alt,$chr_hg19,$pos_hg19,$ref_hg19,$alt_hg19,$gene_id);
    if($lof =~ /HC/){
        print HC $info."\n";
    }elsif(($vep_conseq =~ /inframe_insertion/)or($vep_conseq =~ /inframe_deletion/)){
	if($fathmmXF_result =~ /D/){
            print INFRAME $info."\n";
        }
    }elsif($vep_conseq =~ /synonymous/){
	if($fathmmXF_result =~ /D/){
            print SYN $info."\n";
        }
    }elsif($vep_conseq =~ /missense_variant/){
        print MIS $info."\n";
	if($metasvm_result eq 'D'){
	    print SVM $info."\n";
	}
	#print STDERR $metasvm_result."\n";
    }

}
#CATCH {
#    default {
#        die "Error reading". $input."\n";
#    }
#}
close IN;
if($type eq "snp"){
    close SYN;
    close HC;
    close MIS;
    close SVM;
}elsif($type eq "indel"){
    close INFRAME;
    close HC;
}
