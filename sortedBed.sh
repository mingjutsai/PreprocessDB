#!/bin/bash
unsortedBed=$1
sortedBed=$2
sort -k 1,1 -k2,2n $unsortedBed > $sortedBed
