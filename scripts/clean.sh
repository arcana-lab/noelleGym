#!/bin/bash

rm -f results/current_machine/IR/*/benchmarks/*/*\.ll ;
rm -f log/condor/*.txt ;
rm -f log/condor/*.out ;
rm -f log/condor/*.err ;
rm -f log/condor/*.log ;
rm -f *.con ;

find ./results/ -empty -delete ;

if test -d all_benchmark_suites ; then
  pushd ./ ;
  cd all_benchmark_suites ;
  cd build ;
  for i in `ls` ; do
    if ! test -d $i ; then
      continue ;
    fi
    pushd ./ ;
    cd $i ;
    make clean ;
    popd ;
  done
  popd ;
fi
