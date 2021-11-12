#!/bin/bash -e

function compile_suite {
  local suite=$1 ;

  pushd ./ ;
  cd $suite ;

  # Generate the single bitcode file for all benchmarks of the suite
  make ; 

  # Run our middle-end passes
  make optimization ;

  popd ;

  return ;
}

# Enable NOELLE
source NOELLE/enable ;

# Download the git repository
if ! test -d all_benchmark_suites ; then
  git clone https://github.com/scampanoni/wholeprogram_benchmarks.git all_benchmark_suites
fi

# Setup the git repository
cd all_benchmark_suites ;
make ;

# Compile all benchmark suites
cd build ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
compile_suite "SPEC2017" ;
compile_suite "PolyBench" ;
