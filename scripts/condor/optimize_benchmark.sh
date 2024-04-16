#!/bin/bash

origDir="`pwd`" ;

# Enable external software 
source scripts/source_externals.sh 

# Include compile_benchmark
source scripts/misc.sh

suiteOfBench=$1 ;
benchToOptimize=$2 ;
optimizationName=$3 ;


cd all_benchmark_suites/build/${suiteOfBench} ;
compile_benchmark ${suiteOfBench} ${benchToOptimize} 2>&1 ;
exit 0 ;
