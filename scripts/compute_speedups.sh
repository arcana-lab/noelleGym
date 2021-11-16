#!/bin/bash

function compute_median {
  local inputFile=$1 ;

  # Compute the median 
  sort -g ${inputFile} > ${tempFile} ;
  local numberOfResults=`wc -l ${tempFile} | awk '{print $1}'`;
  local median=`echo "scale=0; $numberOfResults / 2" | bc`;

  # Fetch the median
  awk -v median=$median '
    BEGIN {
      l=0 ;
    } {
      if (l == median){
        print $1 ;
        exit ;
      }
      l++;
    }' $inputFile ;

  return ;
}
function analyze_results {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  # Analyze the data
  pushd ./ ;
  cd ${benchSuite} ;
  local bench;
  for bench in `ls benchmarks` ; do
    if ! test -e benchmarks/${bench}/${bench} ; then
      continue ;
    fi

    # Check if the benchmark run
    outputFile="${currentResults}/${bench}.txt" ;
    if ! test -e $outputFile ; then
      continue ;
    fi

    # Fetch the baseline time
    baselineResults="${dirResult}/${currentDirectory}/baseline/${bench}.txt" ;
    if ! test -f $baselineResults ; then
      continue ;
    fi
    echo "    Benchmark $bench" ;
    baselineTime=`compute_median "$baselineResults"` ;

    # Fetch the optimization time
    optTime=`compute_median "$outputFile"` ;

    # Compute the speedup
    speedup=`echo "scale=3; $baselineTime / $optTime" | bc`;

    # Dump the speedup
    echo "${bench} ${speedup}" >> "${dirResult}/${currentDirectory}/${optimizationName}.txt" ;
  done
  popd ;

  return ;
}

# Define the directory where we are going to dump the results
origDir=`pwd` ;
dirResult="${origDir}/results/current_machine/time"; 

# Create a temporary file
tempFile=`mktemp` ;

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd all_benchmark_suites/build ;
for currentDirectory in `ls` ; do
  if ! test -d $currentDirectory ; then
    continue ;
  fi

  # Consider all optimizations
  for optimizationName in DOALL HELIX DSWP ; do
    echo "Optimization $optimizationName" ;

    # Clean previous files
    rm -f "${dirResult}/${currentDirectory}/${optimizationName}.txt" ;

    # Check if we have results for the current benchmark suite
    currentResults="${dirResult}/${currentDirectory}/${optimizationName}" ;
    if ! test -d $currentResults ; then
      continue ;
    fi

    # Analyze the results
    echo "  Benchmark suite $currentDirectory" ;
    analyze_results $currentDirectory ;
  done

  echo "" ;
done
popd ;

# Clean
rm $tempFile ;
