#!/bin/bash

function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the baseline IR has been generated
  if ! test -f ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_with_metadata.bc ; then
    return ;
  fi

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_${optimizationName}.bc ; then
    return ;
  fi
  echo "Optimizing $benchToOptimize using ${optimizationName}" ;
  echo "  File that will be generated = ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_${optimizationName}.bc";

  # Copy the code to parallelize
  cp ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_with_metadata.bc benchmarks/${benchToOptimize}/ ;

  # Check if there is a benchmark-specific makefile
  if test -f ${origDir}/makefiles/${suite}/${optimizationName}/${benchToOptimize}/Makefile ; then
    cp ${origDir}/makefiles/${suite}/${optimizationName}/${benchToOptimize}/* makefiles/ ;
  else

    # Copy the optimization-specific makefile
    cp ${origDir}/makefiles/${suite}/${optimizationName}/* makefiles/ ;
  fi

  # The benchmark needs to be optimized
  make optimization BENCHMARK=$benchToOptimize ;

  return ;
}

function compile_suite {
  local suite=$1 ;

  pushd ./ &> /dev/null ;
  cd $suite ;

  # Check if the benchmark suite has been compiled
  if ! test -d benchmarks ; then
    popd &> /dev/null ;
    return ;
  fi

  # Copy the baseline IR 
  make clean &> /dev/null ; 
  make bitcode_copy ;

  # Fetch the benchmarks that might need to be optimized
  for bench in `ls benchmarks` ; do
    compile_benchmark $suite $bench ;
  done

  popd ;
  return ;
}

# Fetch the inputs
if test $# -lt 1 ; then
  echo "USAGE: `basename $0` OPTIMIZATION" ;
  exit 1;
fi
optimizationName="$1" ;
origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Compile all benchmark suites
cd all_benchmark_suites/build ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
compile_suite "PolyBench" ;
compile_suite "NAS" ;
if ! test -z ${NOELLE_SPEC} ; then
  compile_suite "SPEC2017" ;
fi

# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/noelle_output.txt` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName

  # Copy the optimized IR file
  mkdir -p ${outputDir}/IR/${dirName} ;
  if test -f ${dirName}/baseline_parallelized.bc ; then
    cp ${dirName}/baseline_parallelized.bc ${outputDir}/IR/${dirName}/baseline_parallelized_${optimizationName}.bc ;
  fi

  # Copy the NOELLE output if it exists 
  cp ${dirName}/noelle_output.txt ${outputDir}/IR/${dirName}/baseline_parallelized_${optimizationName}_noelle_output.txt ;
done
