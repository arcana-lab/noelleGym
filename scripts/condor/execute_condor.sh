#!/bin/bash -e

# Fetch the inputs
if test $# -lt 4; then
  echo "USAGE: `basename $0` JOB NAME UNSPECIFIED" ;
  exit 1;
fi


repoPath=$1 ;
jobDir=$2 ;
jobFile=$3 ;
jobParams=$4 ;

# Go to the repository
cd ${repoPath} ;

./${jobDir}/${jobFile} `echo ${jobParams}`;
