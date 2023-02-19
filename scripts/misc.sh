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
