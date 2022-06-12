#!/bin/bash -e

# Fetch the input
if test $# -lt 2 ; then
  echo "USAGE: `basename $0` TIME_DIR PLOTS_DIR (OPTIONAL)PRALLELIZATION_TECHNIQUES" ;
  exit 1;
fi
timeDir=$1 ;
plotsDir=$2 ;

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

python3 ${repoPath}/scripts/barplotSpeedup.py ${timeDir} ${plotsDir} ${@:3} ;