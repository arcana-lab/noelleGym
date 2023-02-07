#!/bin/bash

cd results/current_machine/IR ;
for suite in `ls` ; do
  pushd ./ &>/dev/null ;
  cd ${suite}/benchmarks ;

  for bench in `ls` ; do
    pushd ./ &>/dev/null ;
    cd $bench ;
    if test -f baseline_with_metadata.bc ; then
      cp baseline_with_metadata.bc baseline_parallelized_NONE.bc ;
    fi
    popd &>/dev/null ;
  done

  popd &>/dev/null ;
done
