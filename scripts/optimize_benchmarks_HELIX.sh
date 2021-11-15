#!/bin/bash

function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_HELIX.bc ; then
    return ;
  fi

  # The benchmark needs to be optimized
  make optimization BENCHMARK=$benchToOptimize ;

  return ;
}

function compile_suite {
  local suite=$1 ;

  pushd ./ ;
  cd $suite ;

  # Check if the benchmark suite has been compiled
  if ! test -d benchmarks ; then
    return ;
  fi

  # Copy the baseline IR 
  make clean ; 
  make bitcode_copy ;

  # Copy the HELIX makefile
  cp ${origDir}/makefiles/${suite}/HELIX/Makefile makefiles/ ;

  # Fetch the benchmarks that might need to be optimized
  for bench in `ls benchmarks` ; do
    compile_benchmark $suite $bench ;
  done

  popd ;
  return ;
}

origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Compile all benchmark suites
cd all_benchmark_suites/build ;
#compile_suite "MiBench" ;
#compile_suite "PARSEC3" ;
#compile_suite "SPEC2017" ;
compile_suite "PolyBench" ;

# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/baseline_parallelized.bc` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName
  mkdir -p ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_parallelized.bc ${outputDir}/IR/${dirName}/baseline_parallelized_HELIX.bc ;
done
