#!/bin/bash

# Fetch the inputs
if test $# -lt 2 ; then
  echo "USAGE: `basename $0` IR_DIR OUTPUT_DIR" ;
  exit 1;
fi
IRDir="$1" ;
outDir="$2" ;
echo "Analyze IRs stored in \"$IRDir\"" ;
echo "Results will be stored in \"$outDir\"" ;

# Clean from previous runs
mkdir -p ${outDir} ;
rm -f ${outDir}/*/DOALL.txt ${outDir}/*/HELIX.txt ${outDir}/*/DSWP.txt ;

# Analyze all IRs parallelized
for irFile in `find $IRDir -iname baseline_parallelized*.bc` ; do
  benchDir="`dirname $irFile`" ;
  benchSuiteDir="`dirname $benchDir`" ;
  benchSuiteDir="`dirname $benchSuiteDir`" ;
  benchSuiteDir="`basename $benchSuiteDir`" ;
  benchName="`basename $benchDir`" ;
  parallelizationName=`echo $irFile | sed 's/.*parallelized_//' | sed 's/\.bc//'`
  echo "  Benchmark $benchName with $parallelizationName" ;

  # Compute the statistics
  rm -f ${benchDir}/*.ll ;
  llvm-dis $irFile ;
  DOALLNums=`grep call $irFile ${benchDir}/*.ll  | grep @NOELLE_DOALLDispatcher | wc -l | awk '{print $1}'` ;
  HELIXNums=`grep call $irFile ${benchDir}/*.ll  | grep @NOELLE_HELIX_dispatcher | wc -l | awk '{print $1}'` ;
  DSWPNums=`grep call $irFile ${benchDir}/*.ll  | grep @NOELLE_DSWPDispatcher | wc -l | awk '{print $1}'` ;

  # Dump
  mkdir -p ${outDir}/${benchSuiteDir} ;
  echo "$benchName $DOALLNums $HELIXNums $DSWPNums" >> ${outDir}/${benchSuiteDir}/${parallelizationName}.txt ;
done
