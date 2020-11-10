#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl 1000g2Annovar.pl vcf.gz\n";die;
}
my $output = $input."_annovar";
open OUT,">",$output;
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
    #if($alt =~ /,/){
        my @alt = split(/,/,$alt);
	my $alt_no = scalar(@alt);
	for(my $no=0;$no<$alt_no;$no++){
	    my $annovar_info .= $pos_info."\t".$alt[$no];
	    foreach my $i (@info){
	        if($i =~ /^AF=/){
		    my @tmp = split(/=/,$i);
		    my @value = split(/,/,$tmp[1]);
		    #$annovar_info .= "\tALL_AF=".$value[$no];
		    $annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^EAS_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    #$annovar_info .= "\tEAS_AF=".$value[$no];
		    $annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^AMR_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    #$annovar_info .= "\tAMR_AF=".$value[$no];
		    $annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^AFR_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    #$annovar_info .= "\tAFR_AF=".$value[$no];
		    $annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^EUR_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    #$annovar_info .= "\tEUR_AF=".$value[$no];
		    $annovar_info .= "\t".$value[$no];
		}elsif($i =~ /^SAS_AF=/){
		    my @tmp = split(/=/,$i);
                    my @value = split(/,/,$tmp[1]);
		    #$annovar_info .= "\tSAS_AF=".$value[$no];
		    $annovar_info .= "\t".$value[$no];
		}
	    }
	    print OUT $annovar_info."\n";
	}
	#die;
    #}
    
}
