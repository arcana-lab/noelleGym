#!/bin/bash

function generate_loop_results {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  # Create the output directory
  currentIVResult="${ivResult}/${benchSuite}" ;
  mkdir -p $currentIVResult ;

  # Collect the data
  pushd ./ ;
  cd ${benchSuite}/benchmarks ;
  for i in `ls` ; do
    if ! test -d $i ; then
      continue ;
    fi
    if ! test -e ${i}/baseline_with_metadata.bc ; then
      continue ;
    fi

    pushd ./ ;
    cd $i ;
    mkdir -p ${currentIVResult}/raw ;
    if ! test -e ${currentIVResult}/raw/${i}.txt ; then
      noelle-loop-stats baseline_with_metadata.bc &> ${currentIVResult}/raw/${i}.txt
    fi
    popd ;
  done
  popd ;
}

function analyze_results {
  local benchSuite="$1" ;
  currentIVResult="${ivResult}/${benchSuite}" ;

  # Check if the benchmark suite has raw data
  if ! test -d ${currentIVResult}/raw ; then
    return ;
  fi

  # Analyze the data
  pushd ./ ;
  cd ${currentIVResult}/raw ; 
  if ! test -e ../induction_variables.txt ; then
    ${origDir}/scripts/extract_IV.sh > ../induction_variables.txt
  fi
  if ! test -e ../invariants.txt ; then
    ${origDir}/scripts/extract_invariants.sh > ../invariants.txt
  fi
  popd ;

  return ;
}

# Define the directory where we are going to dump the results
origDir=`pwd` ;
ivResult="${origDir}/results/current_machine/loops"; 

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd all_benchmark_suites/build ;
for i in `ls` ; do
  if ! test -d $i ; then
    continue ;
  fi
  echo "Benchmark suite $i" ;

  # Generate the raw data
  generate_loop_results $i ;

  # Analyze the raw data
  analyze_results $i ;
done
popd ;
