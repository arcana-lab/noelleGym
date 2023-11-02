#!/bin/bash

rm -f results/current_machine/IR/*/benchmarks/*/*\.ll ;
rm -f log/condor/*.txt ;
rm -f log/condor/*.out ;
rm -f log/condor/*.err ;
rm -f log/condor/*.log ;
rm -f *.con ;
rm -f tmp.* ;

find ./results/ -empty -delete ;

if test -d all_benchmark_suites ; then
  pushd ./ &>/dev/null ;
  cd all_benchmark_suites ;
  cd build ;
  for i in `ls` ; do
    if ! test -d $i ; then
      continue ;
    fi
    pushd ./ &>/dev/null ;
    cd $i ;
    make clean &> /dev/null ;
    popd &>/dev/null ;
  done
  popd &>/dev/null ;
fi
