#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl gnomAD2Annovar.pl vcf.bgz\n";die;
}
my $output = $input."_annovar";
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\tgnomAD_All\tgnomAD_EAS\tgnomAD_AMR\tgnomAD_AFR\tgnomAD_NFE\tgnomAD_SAS\n";
open(IN, "gunzip -c $input |") || die "can't open pipe to ".$input."\n";
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    $chr =~ s/chr//;
    my $pos = $ele[1];
    my $ref = $ele[3];
    my $alt = $ele[4];
    my $end = $pos + length($ref) - 1;
    my $pos_info = join("\t",$chr,$pos,$end,$ref,$alt);
    my @info = split(/;/,$ele[7]);
    my $all_af = 0;
    my $eas_af = 0;
    my $amr_af = 0;
    my $afr_af = 0;
    my $nfe_af = 0;
    my $sas_af = 0;
    foreach my $i (@info){
        if($i =~ /^AF=/){
	    my @tmp = split(/=/,$i);
	    $all_af = $tmp[1];
	}elsif($i =~ /^AF-eas=/){
	    my @tmp = split(/=/,$i);
            $eas_af = $tmp[1];
	}elsif($i =~ /^AF-amr=/){
	    my @tmp = split(/=/,$i);
            $amr_af = $tmp[1];
	}elsif($i =~ /^AF-afr=/){
	    my @tmp = split(/=/,$i);
            $afr_af = $tmp[1];
	}elsif($i =~ /^AF-nfe=/){
	    my @tmp = split(/=/,$i);
            $nfe_af = $tmp[1];
	}elsif($i =~ /^AF-sas=/){
	    my @tmp = split(/=/,$i);
            $sas_af = $tmp[1];
	}
    }
    my $annovar_info = join("\t",$chr,$pos,$end,$ref,$alt,$all_af,$eas_af,$amr_af,$afr_af,$nfe_af,$sas_af);
    print OUT $annovar_info."\n";
}
