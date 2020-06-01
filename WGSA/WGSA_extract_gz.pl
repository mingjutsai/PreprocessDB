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
my $no = 0;
my $VEP_ensembl_Consequence_no = 0;
my $VEP_ensembl_LoF_no = 0;
if($input =~ /\.gz$/){
    open(IN, "gunzip -c $input |") || die "can't open pipe to ".$input."\n";
}else{
    open IN,"<",$input;
}
my $line=<IN>;
chomp $line;
if($type eq "snp"){
    open SYN,">",$synonymous;
    print SYN $line;

    open HC,">",$lof_hc;
    print HC $line;
}elsif($type eq "indel"){
   open INFRAME,">",$inframe;
   print INFRAME $line;

   open HC,">",$lof_hc;
   print HC $line;
}
my @ele = split(/\t/,$line);
foreach my $i (@ele){
    if($i eq "VEP_ensembl_LoF"){
        $VEP_ensembl_LoF_no = $no;
    }elsif($i eq "VEP_ensembl_Consequence"){
        $VEP_ensembl_Consequence_no = $no;
    }
    $no++;
}
print STDERR "VEP_ensembl_Lof:".$VEP_ensembl_LoF_no."\tVEP_ensembl_Consequence:".$VEP_ensembl_Consequence_no."\n";
while($line=<IN>){
    chomp $line;
    #print STDERR $line."\n";
    @ele = split(/\t/,$line);
    #print STDERR "VEP_ensembl_LoF:".$ele[$VEP_ensembl_LoF_no]."\nVEP_ensembl_Consequence:".$ele[$VEP_ensembl_Consequence_no]."\n";die;
    my $lof = $ele[$VEP_ensembl_LoF_no];
    my $vep_conseq = $ele[$VEP_ensembl_Consequence_no];
    if($lof =~ /HC/){
        print HC $line."\n";
    }elsif(($vep_conseq =~ /inframe_insertion/)or($vep_conseq =~ /inframe_deletion/)){
        print INFRAME $line."\n";
    }elsif($vep_conseq =~ /synonymous/){
        print SYN $line."\n";
    }

}
CATCH {
    default {
        die "Error reading". $input."\n";
    }
}
close IN;
if($type eq "snp"){
    close SYN;
    close HC;
}elsif($type eq "indel"){
    close INFRAME;
    close HC;
}
