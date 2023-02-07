#!/bin/bash

function generate_time_saved_results {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  # Create the output directory
  currentTimeSavedResult="${timeSavedResult}/${benchSuite}" ;
  mkdir -p $currentTimeSavedResult ;

  # Collect the data
  pushd ./ &> /dev/null ;
  cd ${benchSuite}/benchmarks ;
  for j in `ls` ; do
    if ! test -d $j ; then
      continue ;
    fi
    if ! test -e ${j}/baseline_with_metadata.bc ; then
      continue ;
    fi
    echo "${prefixString}     Benchmark $j" ;

    pushd ./ &> /dev/null ;
    cd $j ;
    mkdir -p ${currentTimeSavedResult}/raw ;
    if ! test -e ${currentTimeSavedResult}/raw/${j}.txt ; then
      noelle-meta-loop-embed baseline_with_metadata.bc -o tmp.bc
      noelle-time-saved tmp.bc &> ${currentTimeSavedResult}/raw/${j}.txt
      rm tmp.bc
    fi
    popd &> /dev/null ;
  done
  popd &> /dev/null ;

  return ;
}

function analyze_results {
  local benchSuite="$1" ;
  currentTimeSavedResult="${timeSavedResult}/${benchSuite}" ;

  # Check if the benchmark suite has raw data
  if ! test -d ${currentTimeSavedResult}/raw ; then
    return ;
  fi

  # Analyze the data
  pushd ./ &> /dev/null ;
  cd ${currentTimeSavedResult}/raw ;
  ${origDir}/scripts/extract_time_saved.sh > ../time_saved.txt ;
  popd &> /dev/null ;

  return ;
}

# Start
prefixString="TimeSaved: " ;
echo "${prefixString} Start" ;

# Define the directory where we are going to dump the results
origDir=`pwd` ;
timeSavedResult="${origDir}/results/current_machine/time_saved"; 

# Check if we have IRs
if ! test -d ${origDir}/results/current_machine/IR ; then
  echo "${prefixString}   No IRs are available" ;
  echo "${prefixString} End";
  exit 0;
fi

# Generate the results for all benchmarks in all benchmark suites
pushd ./ &> /dev/null ;
cd ${origDir}/results/current_machine/IR ;
for i in `ls` ; do
  if ! test -d $i ; then
    continue ;
  fi
  echo "${prefixString}   Benchmark suite $i" ;

  # Generate the raw data
  generate_time_saved_results $i ;

  # Analyze the raw data
  analyze_results $i ;

  echo "${prefixString}";
done
popd &> /dev/null ;

# Exit
echo "${prefixString} End";
