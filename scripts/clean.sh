#!/bin/bash

rm -f results/current_machine/IR/*/benchmarks/*/*\.ll ;
rm -f log/condor/*.txt ;
rm -f log/condor/*.out ;
rm -f log/condor/*.err ;
rm -f log/condor/*.log ;
rm -f *.con ;

find ./results/ -empty -delete ;
