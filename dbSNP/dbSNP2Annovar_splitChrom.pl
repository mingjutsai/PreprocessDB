#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
my $assembly_report = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl 1000g2Annovar.pl vcf.gz assembly_report.txt\n";die;
}
my %mapping;
open AS,"<",$assembly_report;
while(my $line=<AS>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[9];
    $chr =~ s/\r$//;
    $mapping{$ele[6]} = $chr;
}
close AS;
#my $output = $input."_annovar";
#open OUT,">",$output;
#print OUT "#Chr\tStart\tEnd\tRef\tAlt\tRSID\tAF\n";
my $old_chr = "NA";
open(IN, "gunzip -c $input |") || die "can't open pipe to ".$input."\n";
while(my $line=<IN>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $chr = $ele[0];
    if($mapping{$chr}){
        $chr = $mapping{$chr};
	$chr =~ s/chr//;
    }
    my $output = $input."_Chr".$chr."_annovar";
    my $fo;
    if($chr ne $old_chr){
        open $fo,">",$output;
	print $fo "#Chr\tStart\tEnd\tRef\tAlt\tRSID\tAF\n";
    }else{
        open $fo,">>",$output;
    }
    my $pos = $ele[1];
    my $rsid = $ele[2];
    my $ref = $ele[3];
    my $end = $pos + length($ref) - 1;
    my $pos_info = join("\t",$chr,$pos,$end,$ref);
    my $alt = $ele[4];
    my @info = split(/;/,$ele[7]);
    
    #if($alt =~ /,/){
        my @alt = split(/,/,$alt);
	my $alt_no = scalar(@alt);
	for(my $no=1;$no<=$alt_no;$no++){
	    my $final_maf;
	    foreach my $i (@info){
	        if($i =~ /^FREQ=/){
		    my @tmp = split(/\|/,$i);#multiple sources:FREQ=KOREAN:0.9945,0.005479,.|Siberian:0.5,.,0.5
                    foreach my $f (@tmp){
		        $f =~ s/FREQ=//;
			my @tmp2 = split(/:/,$f);
			my $source = $tmp2[0];
			my @af = split(/,/,$tmp2[1]);
                        $final_maf .= $source.":".$af[$no]."|";
		    }
                    $final_maf =~ s/\|$//;
	        }
	    }
	    if(!$final_maf){
	        $final_maf = "NA";
	    }
	    my $alt_no = $no - 1;
	    my $annovar_info = join("\t",$chr,$pos,$end,$ref,$alt[$alt_no],$rsid,$final_maf);
	    print $fo $annovar_info."\n";
	}
	#die;
    #}
   $old_chr = $chr;
    close $fo; 
}
close IN;
