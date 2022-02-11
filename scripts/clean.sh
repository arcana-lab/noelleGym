#!/bin/bash

rm -f results/current_machine/IR/*/benchmarks/*/*\.ll ;
rm -f log/condor/*.txt ;
rm -f *.con ;

find ./results/ -empty -delete ;
