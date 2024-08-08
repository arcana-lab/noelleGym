#!/bin/bash

# Set the number of runs
numRuns=5 ;
if ! test -z ${NOELLE_RUNS} ; then
  numRuns="${NOELLE_RUNS}" ;
fi

function generate_results {
  local benchSuite="$1" ;

  # Check if the benchmark suite has been compiled
  if ! test -d ${benchSuite}/benchmarks ; then
    return ;
  fi

  # Collect the data
  pushd ./ &>/dev/null ;
  cd ${benchSuite} ;
  local bench;
  for bench in `ls benchmarks` ; do

    # Check if the benchmark has been compiled
    if ! test -e benchmarks/${bench}/${bench} ; then
      continue ;
    fi

    # Check if the benchmark has been optimized
    if ! test -e ${origDir}/results/current_machine/IR/${benchSuite}/benchmarks/${bench}/baseline_parallelized_${optimizationName}.bc ; then
      continue ;
    fi

    # Compute how many times the benchmark have run
    outputFile="${currentResults}/${bench}.txt" ;
    executionsDone="0" ;
    if test -e $outputFile ; then

      # The benchmark already run. 
      # Let's check how many times.
      executionsDone=`wc -l $outputFile | awk '{print $1}'` ;
    fi
    
    # Check if we need to run the benchmark more times
    areWeDone=`echo "$executionsDone >= $numRuns" | bc` ;
    if test "$areWeDone" == "1" ; then

      # The benchmark has executed enough times
      continue ;
    fi

    # The benchmark did not execute enough times
    # Compute how many times are left by setting the initial value of the sequence
    executionsDone=`echo "$executionsDone + 1" | bc` ;

    # Create the output file if it doesn't exist already
    touch $outputFile ;

    # Run the benchmark enough times
    echo "    Benchmark $bench ($numRuns runs)" ;
    for i in `seq $executionsDone $numRuns` ; do

        inputToUse="native" ;
        if [ "${benchSuite}" == "SPEC2017" ] ; then
          inputToUse="ref" ;
        fi

        # Run
        make run BENCHMARK=$bench INPUT=${inputToUse} &> ${tempFile} ;
        if test $? -ne 0 ; then
          echo "$b Error during execution" >> ${outputFile} ;
          break ;
        fi

        # Collect the time (assumes that /usr/bin/time -p was used)
        if [ "${benchSuite}" == "NAS" ] ; then
          baselineTime=`cat ${tempFile} | grep "Time in seconds" | awk '{ print $5 }'`
        else
          baselineTime=`cat ${tempFile} | grep real | awk '{ print $2 }'`
        fi

        # Append the time
        echo "$baselineTime" >> ${outputFile} ;

    done
  done
  popd &>/dev/null ;

  return ;
}

# Fetch the inputs
if test $# -lt 1 ; then
  echo "USAGE: `basename $0` OPTIMIZATION" ;
  exit 1;
fi
optimizationName="$1" ;
echo "Run NOELLE binaries for $optimizationName" ;

# Define the directory where we are going to dump the results
origDir=`pwd` ;
dirResult="${origDir}/results/current_machine/time"; 
mkdir -p $dirResult ;

# Create a temporary file
tempFile=`mktemp` ;

# Generate the results for all benchmarks in all benchmark suites
pushd ./ &>/dev/null ;
cd all_benchmark_suites/build ;
for currentDirectory in `ls` ; do
  if ! test -d $currentDirectory ; then
    continue ;
  fi
  echo "  Benchmark suite $currentDirectory" ;

  # Create the output directory
  currentResults="${dirResult}/${currentDirectory}/${optimizationName}" ;
  mkdir -p $currentResults ;

  # Generate the raw data
  generate_results $currentDirectory ;

done
popd &>/dev/null ;

# Clean
rm $tempFile ;
echo "" ;
