#!/bin/bash

function generate_binaries {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi
  if ! test -d ${origDir}/results/current_machine/IR/${benchSuite}/benchmarks ; then
    return ;
  fi

  # Clean the state of the suite
  pushd ./ ;
  cd ${benchSuite} ;
  make clean ;

  # Copy the IR files
  pushd ./ ;
  cd ${origDir}/results/current_machine/IR/${benchSuite}/benchmarks ;
  for j in `ls` ; do

    # Check if the current directory contains a benchmark we compiled
    if ! test -d $j ; then
      continue ;
    fi
    if ! test -e ${j}/NOELLE_input.bc ; then
      continue ;
    fi

    # The benchmark has been compiled and optimized. Let's copy the final IR
    echo "    Benchmark $j" ;
    cp ${j}/NOELLE_input.bc ${origDir}/all_benchmark_suites/build/${benchSuite}/benchmarks/${j}/${j}.bc ;
  done
  popd ;

  # Generate the binaries
  make binary ;

  popd ;
  return ;
}

# Define the directory where we are going to dump the results
origDir=`pwd` ;

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd all_benchmark_suites/build ;
for i in `ls` ; do
  if ! test -d $i ; then
    continue ;
  fi
  echo "  Benchmark suite $i" ;

  # Generate the binaries
  generate_binaries $i ;

done
popd ;

echo "" ;
