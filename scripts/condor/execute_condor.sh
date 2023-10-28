#!/bin/bash -e

# Fetch the inputs
if test $# -lt 3; then
  echo "USAGE: `basename $0` JOB NAME UNSPECIFIED" ;
  exit 1;
fi


repoPath=$1 ;
jobFile=$2 ;
jobParams=$3 ;

# Go to the repository
cd ${repoPath} ;

./${jobFile} `echo ${jobParams}`;
