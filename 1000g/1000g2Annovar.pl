#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl 1000g2Annovar.pl vcf.gz\n";die;
}
my $output = $input."_annovar";
open OUT,">",$output;
print OUT "#Chr\tStart\tEnd\tRef\tAlt\t1000g_ALL\t1000g_EAS\t1000g_AMR\t1000g_AFR\t1000g_EUR\t1000g_SAS\n";
open(IN, "gunzip -c $input |") || die "can't open pipe to ".$input."\n";
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    my $pos = $ele[1];
    my $ref = $ele[3];
    my $end = $pos + length($ref) - 1;
    my $pos_info = join("\t",$chr,$pos,$end,$ref);
    my $alt = $ele[4];
    my @info = split(/;/,$ele[7]);
    my $all_af = 0;
    my $eas_af = 0;
    my $amr_af = 0;
    my $afr_af = 0;
    my $eur_af = 0;
    my $sas_af = 0;
    #if($alt =~ /,/){
        my @alt = split(/,/,$alt);
	my $alt_no = scalar(@alt);
	for(my $no=0;$no<$alt_no;$no++){
	    foreach my $i (@info){
	        if($i =~ /^AF=/){
		    my @tmp = split(/=/,$i);
		    my @value = split(/,/,$tmp[1]);
		    $all_af = $value[$no];
		    #$annovar_info .= "\tALL_AF=".$value[$no];
		    #$annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^EAS_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    $eas_af = $value[$no];
		    #$annovar_info .= "\tEAS_AF=".$value[$no];
		    #$annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^AMR_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    $amr_af = $value[$no];
		    #$annovar_info .= "\tAMR_AF=".$value[$no];
		    #$annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^AFR_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    $afr_af = $value[$no];
		    #$annovar_info .= "\tAFR_AF=".$value[$no];
		    #$annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^EUR_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    $eur_af = $value[$no];
		    #$annovar_info .= "\tEUR_AF=".$value[$no];
		    #$annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^SAS_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    $sas_af = $value[$no];
		    #$annovar_info .= "\tSAS_AF=".$value[$no];
		    #$annovar_info .= "\t".$value[$no];
		}
	    }
	    my $annovar_info = join("\t",$chr,$pos,$end,$ref,$alt[$no],$all_af,$eas_af,$amr_af,$afr_af,$eur_af,$sas_af);
	    print OUT $annovar_info."\n";
	}
	#die;
    #}
    
}
