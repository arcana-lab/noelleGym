#!/bin/bash -e

# Fetch the input
if test $# -lt 2 ; then
  echo "USAGE: `basename $0` TIME_DIR PLOTS_DIR" ;
  exit 1;
fi
timeDir=$1 ;
plotsDir=$2 ;

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

# Setup and source the python virtual environment
source ${repoPath}/scripts/setup_python_virtual_environment.sh ;

# Plot
python3 ./scripts/gather.py ${timeDir}/../ 
python3 ./scripts/perfprof.py \
  --xlimit 1.5 \
  --marker-size 7 \
  --marker '.' \
  --output $plotsDir/parallelization_perfprof.pdf \
  results.csv
rm results*.csv
