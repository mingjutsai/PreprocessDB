#!/usr/bin/perl
use strict;
use warnings;
# Run homer2bed_simple.pl for all chromosomes in parallel (18 threads)
my @chrs = (1..22, "X", "Y");
my @pids;
for my $i (@chrs){
    my $cmd = "perl ~/PreprocessDB/Hi-C/Homer/homer2bed_simple.pl chr${i}.sigInteractions.txt 0.05";
    print STDERR $cmd."\n";
    my $pid = fork();
    if ($pid == 0) {
        exec($cmd);
        exit;
    }
    push @pids, $pid;
    # Limit to 18 parallel jobs
    if (@pids >= 18) {
        waitpid(shift @pids, 0);
    }
}
# Wait for remaining
waitpid($_, 0) for @pids;
