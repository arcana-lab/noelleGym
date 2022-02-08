#!/bin/bash -e

# Fetch the inputs
if test $# -lt 1; then
  echo "USAGE: `basename $0` REPO_DIR" ;
  exit 1;
fi

# Go to the repository
cd $1 ;

# Generate and run the binaries
./bin/runBaseline
