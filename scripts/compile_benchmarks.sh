#!/bin/bash

function compile_benchmark {
  local suiteOfBench=$1 ;
  local benchToOptimize=$2 ;

  # Check if the benchmark has been optimized already
  if test -e ${origDir}/results/current_machine/IR/${suiteOfBench}/benchmarks/${benchToOptimize}/baseline_with_metadata.bc ; then
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
  if test -z ${NOELLE_FINAL} ; then
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

  # Skip SPEC speed versions of the benchmarks
  if test ${suite} == "SPEC2017" -a $benchToOptimize == *_s ; then
    return ;
  fi

  # Copy the optimization-specific makefile
  cp ${origDir}/makefiles/${suite}/NONE/* makefiles/ ;

  # The benchmark needs to be optimized
  echo "    Compile the benchmark $benchToOptimize" ;
  make optimization BENCHMARK=$benchToOptimize ;

  return ;
}

function compile_suite {
  local suite=$1 ;

  pushd ./ &>/dev/null ;
  cd $suite ;
  echo "Considering the benchmark suite $suite" ;

  # Check if the benchmark suite has the baseline IR
  if ! test -d benchmarks ; then

    # The benchmark suite does not have the baseline IR
    echo "  The benchmark suite doesn't have the baseline IR. Skip this suite." ;
    popd &>/dev/null ;
    return ;
  fi

  # Fetch the benchmarks that might need to be optimized
  echo "  Compile benchmarks included in the suite" ;
  for bench in `ls benchmarks` ; do
    compile_benchmark $suite $bench ;
  done

  popd &>/dev/null ;
  return ;
}

origDir="`pwd`" ;

# Enable external software 
source scripts/source_externals.sh 

# Copy the baseline IR files
./scripts/copy_baseline_IRs.sh ;

# Compile all benchmark suites
cd ${origDir}/all_benchmark_suites/build ;
compile_suite "PolyBench" ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
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
  if test -f ${dirName}/baseline_with_metadata.bc ; then
    cp ${dirName}/baseline_with_metadata.bc ${outputDir}/IR/${dirName} ;
  fi

  # Copy the NOELLE output if it exists 
  cp ${dirName}/noelle_output.txt ${outputDir}/IR/${dirName}/baseline_with_metadata_noelle_output.txt ;
done
