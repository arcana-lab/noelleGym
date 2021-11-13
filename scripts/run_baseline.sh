#!/bin/bash

function generate_results {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  # Collect the data
  pushd ./ ;
  cd ${benchSuite} ;
  make run ;
  popd ;

  return ;
}

function analyze_results {
  local benchSuite="$1" ;
  currentResults="${dirResult}/${benchSuite}" ;

  return ;
}

# Define the directory where we are going to dump the results
origDir=`pwd` ;
dirResult="${origDir}/results/current_machine/time"; 

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd all_benchmark_suites/build ;
for i in `ls` ; do
  if ! test -d $i ; then
    continue ;
  fi
  echo "Benchmark suite $i" ;

  # Generate the raw data
  generate_results $i ;

  # Analyze the raw data
  analyze_results $i ;
done
popd ;
