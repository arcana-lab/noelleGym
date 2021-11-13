#!/bin/bash

function generate_binaries {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  # Copy the IR files
  pushd ./ ;
  cd ${origDir}/results/current_machine/IR/${benchSuite}/benchmarks ;
  for j in `ls` ; do
    if ! test -d $j ; then
      continue ;
    fi
    if ! test -e ${j}/NOELLE_input.bc ; then
      continue ;
    fi
    cp ${j}/NOELLE_input.bc ${origDir}/all_benchmark_suites/build/${benchSuite}/benchmarks/${j}/${j}.bc ;
  done
  popd ;

  # Generate the binaries
  cd ${benchSuite} ;
  make binary ;

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
  echo "Benchmark suite $i" ;

  # Generate the binaries
  generate_binaries $i ;

done
popd ;
