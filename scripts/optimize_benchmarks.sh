#!/bin/bash

function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the baseline IR has been generated
  if ! test -f ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/NOELLE_input.bc ; then
    return ;
  fi

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_${optimizationName}.bc ; then
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
    popd ;
    return ;
  fi

  # Copy the baseline IR 
  make clean ; 
  make bitcode_copy ;

  # Copy the optimization-specific makefile
  cp ${origDir}/makefiles/${suite}/${optimizationName}/Makefile makefiles/ ;

  # Fetch the benchmarks that might need to be optimized
  for bench in `ls benchmarks` ; do
    compile_benchmark $suite $bench ;
  done

  popd ;
  return ;
}

# Fetch the inputs
if test $# -lt 1 ; then
  echo "USAGE: `basename $0` OPTIMIZATION" ;
  exit 1;
fi
optimizationName="$1" ;
origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Compile all benchmark suites
cd all_benchmark_suites/build ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
if ! test -z ${NOELLE_SPEC} ; then
  compile_suite "SPEC2017" ;
fi
if ! test -z ${NOELLE_FINAL} ; then
  compile_suite "PolyBench" ;
fi

# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/baseline_parallelized.bc` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName
  mkdir -p ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_parallelized.bc ${outputDir}/IR/${dirName}/baseline_parallelized_${optimizationName}.bc ;
done
