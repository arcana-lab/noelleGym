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
  if ! test -d ${benchSuite}/baseline ; then
    return ;
  fi

  # Analyze the data
  pushd ./ ;
  cd ${benchSuite} ;
  local bench;
  for bench in `ls baseline` ; do

    # Check if the benchmark run
    outputFile="${currentResults}/${bench}" ;
    if ! test -e $outputFile ; then
      continue ;
    fi

    # Fetch the baseline time
    baselineResults="baseline/${bench}" ;
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

# Fetch the input
if test $# -lt 1 ; then
  echo "USAGE: `basename $0` TIME_DIR" ;
  exit 1;
fi
dirResult="$1" ;

# Check the results
if ! test -d $dirResult ; then
  echo "The directory \"${dirResult}\" does not exist" ;
  exit 1;
fi
echo $dirResult ;

# Create a temporary file
origDir=`pwd` ;
tempFile=`mktemp` ;

# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd $dirResult ; 
for currentDirectory in `ls` ; do
  if ! test -d $currentDirectory ; then
    continue ;
  fi
  echo "Benchmark suite $currentDirectory" ;

  # Consider all optimizations
  for optimizationName in DOALL HELIX DSWP NONE ; do

    # Clean previous files
    rm -f "${dirResult}/${currentDirectory}/${optimizationName}.txt" ;

    # Check if we have results for the current benchmark suite
    currentResults="${dirResult}/${currentDirectory}/${optimizationName}" ;
    if ! test -d $currentResults ; then
      continue ;
    fi

    # Analyze the results
    echo "  Optimization $optimizationName" ;
    analyze_results $currentDirectory ;
  done

  echo "" ;
done
popd ;

find ./results -empty -delete;

# Clean
rm $tempFile ;
