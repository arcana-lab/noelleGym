#!/bin/bash -e

# Fetch the inputs
if test $# -lt 2; then
  echo "USAGE: `basename $0` JOB NAME UNSPECIFIED" ;
  exit 1;
fi

# Go to the repository
cd $1 ;

# Check if we need to run only the baseline
jobName=$2 ;
jobParams=$3 ;
outputFile=$4 ;
./bin/$jobName `echo $jobParams` >> $outputFile 2>&1 ;
