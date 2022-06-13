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

function compute_max {
  local inputFile=$1 ;
    
  awk '
    {
      # find maximum value
      max_val = $3;
      max_idx = 3;
      for (i = 5; i <= NF; i += 2) {
        if ($i > max_val) {
          max_val = $i;
          max_idx = i;
        }
      }
      # print benchmark
      #   benchmark opt speedup
      printf "%s %s %s\n", $1, max_val, $(max_idx-1);
    }' ${inputFile}

  return;
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

    if [ ${speedup} != "" ] ; then
      echo "${bench} ${optimizationName} ${speedup}" >> "${dirResult}/${currentDirectory}/${optimizationName}_tmp.txt" ;
    fi
  done
  popd ;

  return ;
}

# Fetch the input
if test $# -lt 2 ; then
  echo "USAGE: `basename $0` TIME_DIR PLOTS_DIR" ;
  exit 1;
fi
dirResult=`realpath "$1"` ;

# Check the results
if ! test -d $dirResult ; then
  echo "The directory \"${dirResult}\" does not exist" ;
  exit 1;
fi
echo $dirResult ;

# Create a temporary file
origDir=`pwd` ;
tempFile=`mktemp` ;

optimizations=( NONE DOALL HELIX DSWP ) ;
# Generate the results for all benchmarks in all benchmark suites
pushd ./ ;
cd $dirResult ; 
for currentDirectory in `ls` ; do
  if ! test -d $currentDirectory ; then
    echo "$currentDirectory not found" ;
    continue ;
  fi
  echo "Benchmark suite $currentDirectory" ;

  # Consider all optimizations
  for optimizationName in ${optimizations[@]} ; do

    # Clean previous files
      rm -f "${dirResult}/${currentDirectory}/${optimizationName}.txt" ;
      rm -f "${dirResult}/${currentDirectory}/${optimizationName}_tmp.txt" ;

    # Check if we have results for the current benchmark suite
    currentResults="${dirResult}/${currentDirectory}/${optimizationName}" ;
    if ! test -d $currentResults ; then
      continue ;
    fi

    # Analyze the results
    echo "  Optimization $optimizationName" ;
    analyze_results $currentDirectory ;
  done

  combinedFile=${dirResult}/${currentDirectory}/NOELLE_ALL.txt ;
  rm -f ${combinedFile} ;
  cp ${dirResult}/${currentDirectory}/NONE_tmp.txt ${combinedFile} ;
  tmp=`mktemp` ;
  for optimizationName in ${optimizations[@]:1} ; do
    tmpResultsFile=${dirResult}/${currentDirectory}/${optimizationName}_tmp.txt ;
    if test -f ${tmpResultsFile} ; then
      join -a1 ${combinedFile} ${tmpResultsFile} > ${tmp};
      cp ${tmp} ${combinedFile} ;
    fi
  done
  rm -f ${tmp} ;

  noelleFile=${dirResult}/${currentDirectory}/NOELLE.txt ;
  compute_max ${combinedFile} > ${noelleFile};

  rm -f ${combinedFile} ;
  for optimizationName in ${optimizations[@]} ; do
    rm -f ${dirResult}/${currentDirectory}/${optimizationName}_tmp.txt;
  done
  
  echo "" ;
done
popd ;

find ./results -empty -delete;

# Clean
rm $tempFile ;

# Prepare the plots directory
plotsDir=`realpath "$2"` ;
echo $plotsDir ;
mkdir -p $plotsDir ;

# Generate plots per benchmark suite
./scripts/barplotSpeedup.sh $dirResult $plotsDir ;