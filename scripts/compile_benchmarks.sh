#!/bin/bash -e

function compile_suite {
  local suite=$1 ;

  pushd ./ ;
  cd $suite ;

  # Generate the single bitcode file for all benchmarks of the suite
  make ; 

  # Run our middle-end passes
  make optimization ;

  popd ;

  return ;
}

origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Download the git repository
if ! test -d all_benchmark_suites ; then
  git clone https://github.com/scampanoni/wholeprogram_benchmarks.git all_benchmark_suites
fi

# Setup the git repository
cd all_benchmark_suites ;
if ! test -e install ; then
  make ;
fi

# Compile all benchmark suites
cd build ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
compile_suite "SPEC2017" ;
compile_suite "PolyBench" ;

# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/baseline_parallelized.bc` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName
  mkdir -p ${outputDir}/IR/${dirName} ;
  cp ${dirName}/NOELLE_input.bc ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_with_metadata.bc ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_parallelized.bc ${outputDir}/IR/${dirName} ;
done
