#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
my $input = $ARGV[0];
my $outputName = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl annovar2CodingFilter.pl annovar_format output_name\n";die;
}
my %uniq;
my $dir = dirname($input);
my $output = $dir."/".$outputName;
open OUT,">",$output;
print OUT "group_id,chr,pos,ref.alt\n";
open IN,"<",$input;
while(my $line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my ($chr,$start,$end,$ref,$alt,$gene) = ($ele[0],$ele[1],$ele[2],$ele[3],$ele[4],$ele[5]);
    my $pos = join(",",$gene,$chr,$start,$ref,$alt);
    if(!$uniq{$pos}){
        print OUT $gene.",".$chr.",".$start.",".$ref.",".$alt."\n";
	$uniq{$pos}++;
    }
}
close IN;
close OUT;

my @uniq = keys %uniq;
my $uniq_no = scalar @uniq;
print STDERR "unique variants:".$uniq_no."\n";
