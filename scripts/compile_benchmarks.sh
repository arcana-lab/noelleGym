#!/bin/bash

function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized.bc ; then
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

  # Generate the single bitcode file for all benchmarks of the suite
  if ! test -d benchmarks ; then
    make ; 
  else
    make clean ; 
    make bitcode_copy ;
  fi

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

# Download the git repository
if ! test -d all_benchmark_suites ; then
  git clone https://github.com/scampanoni/wholeprogram_benchmarks.git all_benchmark_suites
fi

# Setup the git repository
cd all_benchmark_suites ;
if ! test -e install ; then
  make ;
fi

# Compile all benchmark suites
cd build ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
compile_suite "PolyBench" ;
#compile_suite "SPEC2017" ;

# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/baseline_parallelized.bc` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName
  mkdir -p ${outputDir}/IR/${dirName} ;
  cp ${dirName}/NOELLE_input.bc ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_with_metadata.bc ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_parallelized.bc ${outputDir}/IR/${dirName} ;
done
