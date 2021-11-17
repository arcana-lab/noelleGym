#!/bin/bash

function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_parallelized_DOALL.bc ; then
    return ;
  fi

  # Check if we should generate extra data
  if test -z ${NOELLE_FINAL} ; then

    # Check if the benchcmark is part of the list of extra ones
    if test $benchToOptimize == "lame" ; then
      return ;
    fi
    if test $benchToOptimize == "lout" ; then
      return ;
    fi
  fi
  if test -z ${NOELLE_SUBMISSION} ; then
    if test $benchToOptimize == "omnetpp_r" ; then
      return ;
    fi
    if test $benchToOptimize == "perlbench_r" ; then
      return ;
    fi
    if test $benchToOptimize == "x264_r" ; then
      return ;
    fi
    if test $benchToOptimize == "blender_r" ; then
      return ;
    fi
    if test $benchToOptimize == "parest_r" ; then
      return ;
    fi
  fi

  # Copy the optimization-specific makefile
  cp ${origDir}/makefiles/${suite}/DOALL//Makefile makefiles/ ;

  # The benchmark needs to be optimized
  make optimization BENCHMARK=$benchToOptimize ;

  return ;
}

function compile_suite {
  local suite=$1 ;

  pushd ./ ;
  cd $suite ;

  # Generate the single bitcode file for all benchmarks of the suite
  if ! test -d benchmarks ; then

    # Fetch the file name of the archive
    if test "$suite" == "PARSEC3" ; then
      benchmarkSuiteArchive="${origDir}/benchmarkSuites/parsec-3.0.tar.gz"; 
      wget --no-check-certificate http://parsec.cs.princeton.edu/download/3.0/parsec-3.0.tar.gz -O "${benchmarkSuiteArchive}" ;

    elif test "$suite" == "MiBench" ; then
      benchmarkSuiteArchive="${origDir}/benchmarkSuites/mibench-master.tar.bz2"; 

    elif test "$suite" == "PolyBench" ; then
      benchmarkSuiteArchive="${origDir}/benchmarkSuites/polybench-3.1.tar.gz"; 

    else
      benchmarkSuiteArchive="${origDir}/benchmarkSuites/SPEC2017.tar.gz" ;
    fi
    
    # Check if the file exists
    if ! test -e "${benchmarkSuiteArchive}" ; then
      echo "ERROR = The file ${benchmarkSuiteArchive} does not exist" ;
      popd ;
      return ;
    fi

    # Copy the archive and generate a whole-IR file for each benchmark
    make TAR="${benchmarkSuiteArchive}"; 

  else
    make clean ; 
    make bitcode_copy ;
  fi

  # Fetch the benchmarks that might need to be optimized
  for bench in `ls benchmarks` ; do
    compile_benchmark $suite $bench ;
  done

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
if ! test -z ${NOELLE_SPEC} ; then
  compile_suite "SPEC2017" ;
fi
if ! test -z ${NOELLE_FINAL} ; then
  compile_suite "PolyBench" ;
fi

# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/baseline_parallelized.bc` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName
  mkdir -p ${outputDir}/IR/${dirName} ;
  cp ${dirName}/NOELLE_input.bc ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_with_metadata.bc ${outputDir}/IR/${dirName} ;
  cp ${dirName}/baseline_parallelized.bc ${outputDir}/IR/${dirName}/baseline_parallelized_DOALL.bc ;
done
