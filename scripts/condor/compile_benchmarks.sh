#!/bin/bash

benchLogFiles=();

function compile_suite {
  local suite=$1 ;

  pushd ./ &>/dev/null ;
  
  cd ./all_benchmark_suites/build/${suite} ;
  echo "Considering the benchmark suite ${suite}" ;

  # Check if the benchmark suite has the baseline IR
  if ! test -d benchmarks ; then

    # The benchmark suite does not have the baseline IR
    echo "  The benchmark suite doesn't have the baseline IR. Skip this suite." ;
    popd &>/dev/null ;
    return ;
  fi

  # Fetch the benchmarks that might need to be optimized
  echo "  Compile benchmarks included in the suite" ;
  benchmarksDir="`pwd`/benchmarks";
  popd &>/dev/null ;
  for bench in `ls ${benchmarksDir}` ; do

    # Check if the benchmark directory exists
    if ! test -d ${benchmarksDir}/${bench} ; then
      continue ;
    fi

    # Check if the benchmark has been already compiled for the baseline
    if test -e ${outputDir}/IR/${suite}/benchmarks/${bench}/baseline_with_metadata.bc ; then
      continue ;
    fi
    echo "    Compile benchmark ${bench}" ;

    # Compile the benchmark
    # This is equivalent to compile_benchmark $suite $bench ;
    local benchLogFile=$(./bin/submitCondor "default" "0" "scripts/condor/compile_benchmark.sh" "'${suite} ${bench}'" "output.txt");
    benchLogFiles+=($benchLogFile) ;
  done

  return ;
}

# Set the directories
origDir="`pwd`" ;
outputDir="${origDir}/results/current_machine" ;

# Enable external software 
source scripts/source_externals.sh 

# Copy the baseline IR files
./scripts/copy_baseline_IRs.sh ;

# Compile all benchmark suites
compile_suite "PolyBench" ;
compile_suite "MiBench" ;
compile_suite "PARSEC3" ;
compile_suite "NAS" ;
if ! test -z ${NOELLE_SPEC} ; then
  compile_suite "SPEC2017" ;
fi

# Wait until all jobs done
./bin/condorWait ${benchLogFiles[@]} ;

# Copy condor job outputs into output.txt
# Echo of this script is redirected into output.txt, so no need for >>
for benchLogFile in ${benchLogFiles[@]} ; do
  benchOutputFile=${benchLogFile%".log"}.out ;
  cat ${benchOutputFile} ;
done



# Cache the bitcode files

cd ${origDir}/all_benchmark_suites/build ;
for i in `ls */benchmarks/*/noelle_output.txt` ; do
  echo $i ;

  dirName="`dirname $i`" ;
  echo $dirName ;

  # Copy the optimized IR file
  mkdir -p ${outputDir}/IR/${dirName} ;
  if test -f ${dirName}/baseline_with_metadata.bc ; then
    cp ${dirName}/baseline_with_metadata.bc ${outputDir}/IR/${dirName} ;
  fi

  # Copy the NOELLE output if it exists 
  cp ${dirName}/noelle_output.txt ${outputDir}/IR/${dirName}/baseline_with_metadata_noelle_output.txt ;

done
