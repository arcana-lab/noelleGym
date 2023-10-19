#!/bin/bash

function are_all_benchmarks_run {
  local benchSuite="$1" ;
  local optimizationName="$2" ;
  local origDir="`pwd`" ;
  local dirResult="${origDir}/results/current_machine/time"; 
  local currentResults="${dirResult}/${benchSuite}/${optimizationName}" ;

  # Check if the benchmark suite has been compiled
  pushd ./ &> /dev/null ;
  cd ${origDir}/all_benchmark_suites/build ;
  if ! test -d ${benchSuite}/benchmarks ; then
    popd &> /dev/null ;
    echo "0" ;
    return ;
  fi

  # Collect the data
  cd ${benchSuite} ;
  local bench;
  local didAllRun;
  didAllRun="1" ;
  for bench in `ls benchmarks` ; do

    # Check if the benchmark has been optimized
    if ! test -e ${origDir}/results/current_machine/IR/${benchSuite}/benchmarks/${bench}/baseline_parallelized_${optimizationName}.bc ; then
      continue ;
    fi

    # Check if the benchmark already run
    outputFile="${currentResults}/${bench}.txt" ;
    if ! test -e $outputFile ; then
      didAllRun="0" ;
      break ;
    fi
  done
  popd &>/dev/null ;

  echo "$didAllRun" ;
  return ;
}

function are_all_benchmarks_run_for_all_suites {
  local optimizationName="$1" ;
  
  for i in `ls results/current_machine/IR` ; do
    didTheyRun=$(are_all_benchmarks_run "$i" $optimizationName);
    if test "$didTheyRun" == "0" ; then
      echo "0" ;
      return ;
    fi
  done

  echo "1" ;
  return ;
}

# Must be called from within all_benchmark_suites/build/{suite}
# $origDir must be set to noelleGym base directory
# $optimizationName must be one of {NONE, DOALL, HELIX, DSWP}
#
# If either the baseline IR is missing or the parallelized IR
# is present (in either all_benchmark_suites/build/{suite}/{bench}
# or results/current_machine/IR/{suite}/benchmarks/{bench}), 
# compile_benchmark will have no effect.
#
# compile_benchmark will write only to all_benchmark_suites/
# build/{suite}/{bench}. bin/compile and related scripts copy
# baseline_parallelized.bc and noelle_output.txt to results.
function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the baseline IR has been generated
  if ! test -f ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_with_metadata.bc ; then
    return ;
  fi

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_${optimizationName}.bc ; then
    return ;
  fi
  echo "Optimizing $benchToOptimize using ${optimizationName}" ;
  echo "  File that will be generated = ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_${optimizationName}.bc";

  # Copy the code to parallelize
  cp ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_with_metadata.bc benchmarks/${benchToOptimize}/ ;

  # Check if there is a benchmark-specific makefile
  if test -f ${origDir}/makefiles/${suite}/${optimizationName}/${benchToOptimize}/Makefile ; then
    cp ${origDir}/makefiles/${suite}/${optimizationName}/${benchToOptimize}/* makefiles/ ;
  else

    # Copy the optimization-specific makefile
    cp ${origDir}/makefiles/${suite}/${optimizationName}/* makefiles/ ;
  fi

  # The benchmark needs to be optimized
  make optimization BENCHMARK=$benchToOptimize ;

  echo "";
  return ;
}
