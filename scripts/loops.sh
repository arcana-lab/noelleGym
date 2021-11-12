#!/bin/bash

function generate_loop_results {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  currentIVResult="${ivResult}/${benchSuite}" ;
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  pushd ./ ;
  mkdir -p $currentIVResult ;
  cd ${benchSuite}/benchmarks ;
  for i in `ls` ; do
    if ! test -d $i ; then
      continue ;
    fi
    pushd ./ ;
    cd $i ;
    if ! test -e ; then
      continue ;
    fi

    noelle-loop-stats baseline_with_metadata.bc &> ${currentIVResult}/${i}.txt
    popd ;
  done
  popd ;
}


# Define the directory where we are going to dump the results
origDir=`pwd` ;
ivResult="${origDir}/results/current_machine/loops"; 

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd build ;
for i in `ls` ; do
  if ! test -d $i ; then
    continue ;
  fi
  echo "Benchmark suite $i" ;

  generate_loop_results $i ;
done
popd ;
