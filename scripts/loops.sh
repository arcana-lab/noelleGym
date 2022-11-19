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
  for j in `ls` ; do
    if ! test -d $j ; then
      continue ;
    fi
    if ! test -e ${j}/baseline_with_metadata.bc ; then
      continue ;
    fi
    echo "${prefixString}     Benchmark $j" ;

    pushd ./ ;
    cd $j ;
    mkdir -p ${currentIVResult}/raw ;
    if ! test -e ${currentIVResult}/raw/${j}.txt ; then
      noelle-meta-loop-embed baseline_with_metadata.bc -o baseline_with_loop_metadata.bc ;
      noelle-loop-stats baseline_with_loop_metadata.bc &> ${currentIVResult}/raw/${j}.txt ;
    fi
    popd ;
  done
  popd ;

  return ;
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
  if ! test -e ../dynamic_ir_insts.txt ; then
    ${origDir}/scripts/extract_dynamic_ir_insts.sh > ../dynamic_ir_insts.txt ;
  fi
  popd ;

  return ;
}

# Start
prefixString="Loops: " ;
echo "${prefixString} Start" ;

# Define the directory where we are going to dump the results
origDir=`pwd` ;
ivResult="${origDir}/results/current_machine/loops"; 

# Check if we have IRs
if ! test -d ${origDir}/results/current_machine/IR ; then
  echo "${prefixString}   No IRs are available" ;
  echo "${prefixString} End";
  exit 0;
fi

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd ${origDir}/results/current_machine/IR ;
for i in `ls` ; do
  if ! test -d $i ; then
    continue ;
  fi
  echo "${prefixString}   Benchmark suite $i" ;

  # Generate the raw data
  generate_loop_results $i ;

  # Analyze the raw data
  analyze_results $i ;

  echo "${prefixString}";
done
popd ;

# Exit
echo "${prefixString} End";
