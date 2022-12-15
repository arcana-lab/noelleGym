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
rm -f ${outDir}/*/DOALL.txt ${outDir}/*/HELIX.txt ${outDir}/*/DSWP.txt ${outDir}/*/NONE.txt ;

# Analyze all IRs parallelized
for irFile in `find $IRDir -iname baseline_parallelized*.bc` ; do

  # Fetch the names
  benchDir="`dirname $irFile`" ;
  benchSuiteDir="`dirname $benchDir`" ;
  benchSuiteDir="`dirname $benchSuiteDir`" ;
  benchSuiteDir="`basename $benchSuiteDir`" ;
  benchName="`basename $benchDir`" ;
  relativeIRFile="`basename $irFile`" ;
  outputFileName="`echo $relativeIRFile | sed 's/\.bc//g'`";
  outputFileName="${outputFileName}_noelle_output.txt" ;
  if ! test -f ${benchDir}/$outputFileName ; then
    echo "ERROR: output file for $irFile does not exist" ;
    echo "The file should have been ${benchDir}/${outputFileName}" ;
    exit 1;
  fi
  parallelizationName=`echo $irFile | sed 's/.*parallelized_//' | sed 's/\.bc//'`
  echo "  Benchmark $benchName with $parallelizationName" ;

  # Compute the statistics
  DOALLNums=`grep "The loop has been parallelized with DOALL" ${benchDir}/${outputFileName} | grep "Parallelizer: parallelizerLoop" | wc -l | awk '{print $1}'` ;
  HELIXNums=`grep "The loop has been parallelized with HELIX" ${benchDir}/${outputFileName} | grep "Parallelizer: parallelizerLoop" | wc -l | awk '{print $1}'` ;
  DSWPNums=`grep "The loop has been parallelized with DSWP" ${benchDir}/${outputFileName} | grep "Parallelizer: parallelizerLoop" | wc -l | awk '{print $1}'` ;

  # Dump
  mkdir -p ${outDir}/${benchSuiteDir} ;
  echo "$benchName $DOALLNums $HELIXNums $DSWPNums" >> ${outDir}/${benchSuiteDir}/${parallelizationName}.txt ;
done
