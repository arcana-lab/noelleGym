#!/bin/bash

origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Include compile_benchmark
source scripts/misc.sh

suiteOfBench=$1 ;
benchToOptimize=$2 ;
optimizationName=$3 ;


cd all_benchmark_suites/build/${suiteOfBench} ;
compile_benchmark ${suiteOfBench} ${benchToOptimize} 2>&1 ;
exit 0 ;