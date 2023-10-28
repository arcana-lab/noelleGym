#!/bin/bash

function compile_benchmark {

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_with_metadata.bc ; then
    return ;
  fi

  # Check if we should generate extra data
  if test -z ${NOELLE_FINAL} ; then

    # Check if the benchcmark is part of the list of extra ones
    if test ${benchToOptimize} == "lame" ; then
      return ;
    fi
    if test ${benchToOptimize} == "lout" ; then
      return ;
    fi
  fi
  if test -z ${NOELLE_FINAL} ; then
    if test ${benchToOptimize} == "omnetpp_r" ; then
      return ;
    fi
    if test ${benchToOptimize} == "perlbench_r" ; then
      return ;
    fi
    if test ${benchToOptimize} == "x264_r" ; then
      return ;
    fi
    if test ${benchToOptimize} == "blender_r" ; then
      return ;
    fi
    if test ${benchToOptimize} == "parest_r" ; then
      return ;
    fi
  fi

  # Skip SPEC speed versions of the benchmarks
  if test ${suiteOfBench} == "SPEC2017" -a ${benchToOptimize} == *_s ; then
    return ;
  fi

  # Enter the suite folder of the benchmark
  cd ${origDir}/all_benchmark_suites/build/${suiteOfBench}/ ;

  # Copy the optimization-specific makefile
  cp ${origDir}/makefiles/${suiteOfBench}/NONE/* makefiles/ ;

  # The benchmark needs to be optimized
  echo "    Compile the benchmark ${suiteOfBench}/${benchToOptimize}" ;
  make optimization BENCHMARK=${benchToOptimize} ;

  return ;
}



suiteOfBench=$1 ;
benchToOptimize=$2 ;
origDir="`pwd`" ;

compile_benchmark ;
