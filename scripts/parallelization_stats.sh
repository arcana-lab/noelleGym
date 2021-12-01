#!/bin/bash

# Fetch the inputs
if test $# -lt 1 ; then
  echo "USAGE: `basename $0` DIR" ;
  exit 1;
fi
IRDir="$1" ;
echo "Analyze IRs stored in \"$IRDir\"" ;

# Clean from previous runs
rm -f DOALL.txt HELIX.txt DSWP.txt ;

# Analyze all IRs parallelized
for irFile in `find $IRDir -iname baseline_parallelized*.bc` ; do
  benchDir="`dirname $irFile`" ;
  benchName="`basename $benchDir`" ;
  parallelizationName=`echo $irFile | sed 's/.*parallelized_//' | sed 's/\.bc//'`
  echo "  Benchmark $benchName with $parallelizationName" ;

  # Compute the statistics
  rm -f ${benchDir}/*.ll ;
  llvm-dis $irFile ;
  DOALLNums=`grep call $irFile ${benchDir}/*.ll  | grep @NOELLE_DOALLDispatcher | wc -l | awk '{print $1}'` ;
  HELIXNums=`grep call $irFile ${benchDir}/*.ll  | grep @NOELLE_HELIX_dispatcher | wc -l | awk '{print $1}'` ;

  # Dump
  echo "$benchName $DOALLNums $HELIXNums 0" >> ${parallelizationName}.txt ;
done
