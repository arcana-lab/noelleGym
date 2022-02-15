#!/bin/bash -e

# Fetch the inputs
if test $# -lt 2; then
  echo "USAGE: `basename $0` REPO_DIR RUN_BASELINE_ONLY" ;
  exit 1;
fi

# Go to the repository
cd $1 ;

# Check if we need to run only the baseline
if test $2 == "baseline" ; then

  # Generate and run the binaries for the baseline
  ./bin/runBaseline ;
  exit 0;
fi

# Check if we need to run only the enablers
if test $2 == "all" ; then

  # Run
  ./bin/run ;
  exit 0;
fi

# Generate and run the binaries for the baseline
./bin/runTechnique $2 ;
