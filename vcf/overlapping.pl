#!/usr/bin/perl
use strict;
use warnings;
my $major = $ARGV[0];
my $minor = $ARGV[1];
if(@ARGV < 2){
    print STDERR "perl overlapping.pl major_annovar minor_annovar\n";die;
}
my %major;
open MAJ,"<",$major;
while(my $line=<MAJ>){
    chomp $line;
    if($line =~ /^#/){
        next;
    }
    my @ele = split(/\t/,$line);
    my $pos = join("\t",$ele[0],$ele[1],$ele[2],$ele[3],$ele[4]);
    $major{$pos}++;
}
close MAJ;

my $total_no = 0;
my $match_no = 0;
my $match_output = $minor."_match";
my $unmatch_output = $minor."_unmatch";
open MATCH,">",$match_output;
open UNMATCH,">",$unmatch_output;
open MINOR,"<",$minor;
while(my $line=<MINOR>){
    chomp $line;
    if($line =~ /^#/){
	    next;
    }
    my @ele = split(/\t/,$line);
    my $pos = join("\t",$ele[0],$ele[1],$ele[2],$ele[3],$ele[4]);
    if($major{$pos}){
	$match_no++;
	print MATCH $line."\n";
    }else{
        print UNMATCH $line."\n";
    }
    $total_no++;
}
close MINOR;


print STDERR "File:".$minor." has ".$total_no." variants, and ".$match_no." variants in ".$major."\n";
my $ratio = $match_no/$total_no;
print STDERR "Ratio:".$ratio."\n";
close MATCH;
close UNMATCH;
