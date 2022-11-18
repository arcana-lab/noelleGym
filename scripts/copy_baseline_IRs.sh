#!/bin/bash

function compile_suite {
  local suite=$1 ;

  pushd ./ ;
  cd $suite ;
  echo "Compile the benchmark suite $suite" ;

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

    elif test "$suite" == "NAS" ; then
      benchmarkSuiteArchive="${origDir}/benchmarkSuites/NAS.tgz"; 
      wget https://github.com/benchmark-subsetting/NPB3.0-omp-C/tarball/master -O "${benchmarkSuiteArchive}" ;

    else
      benchmarkSuiteArchive="${origDir}/benchmarkSuites/SPEC2017.tar.gz" ;
      if ! test -f $benchmarkSuiteArchive ; then
        if test -f /project/benchmarks/SPEC2017.tar.gz ; then
          cp /project/benchmarks/SPEC2017.tar.gz $benchmarkSuiteArchive ;
        fi
      fi
    fi
    
    # Check if the file exists
    if ! test -e "${benchmarkSuiteArchive}" ; then
      echo "ERROR = The file ${benchmarkSuiteArchive} does not exist. " ;
      popd ;
      return ;
    fi

    # Copy the archive and generate a whole-IR file for each benchmark
    echo "  Benchmarks need to be translated into a single-IR file" ;
    make TAR="${benchmarkSuiteArchive}"; 

  else
    echo "  Copy the single-IR files of benchmarks" ;
    make clean ; 
    make bitcode_copy ;
  fi

  popd ;
  return ;
}

origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Compile all benchmark suites
cd all_benchmark_suites/build ;
compile_suite "PolyBench" ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
compile_suite "NAS" ;
if ! test -z ${NOELLE_SPEC} ; then
  compile_suite "SPEC2017" ;
fi

# Cache the bitcode files
echo "Copy the IRs" ;
outputDir="${origDir}/results/current_machine" ;
for i in `ls */benchmarks/*/*.bc` ; do
  fileName="`basename $i`";
  if [[ $fileName == "NOELLE"* ]] ; then
    continue ;
  fi
  if [[ $fileName == "all.bc" ]] ; then
    continue ;
  fi

  # Create the output directory
  dirName="`dirname $i`" ;
  mkdir -p ${outputDir}/IR/${dirName} ;

  # Copy the IR
  if test -f ${outputDir}/IR/${dirName}/NOELLE_input.bc ; then
    cmp $i ${outputDir}/IR/${dirName}/NOELLE_input.bc &> /dev/null ;
    if test $? -ne 0 ; then
      echo "ERROR: The IR in \"${outputDir}\" does not match the single bitcode IR stored in the benchmark suite" ;
      echo "       Previous IR = ${outputDir}/IR/${dirName}/NOELLE_input.bc";
      echo "       IR in the benchmark suite: $i" ;
      exit 1;
    fi

  else 
    echo "  Copy the IR $i" ;
    cp $i ${outputDir}/IR/${dirName}/NOELLE_input.bc ;
  fi
done
