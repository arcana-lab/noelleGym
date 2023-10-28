#!/bin/bash

benchLogFiles=();

function compile_suite {
  local suite=$1 ;

  pushd ./ &> /dev/null ;

  cd ./all_benchmark_suites/build/${suite} ;
  echo "Parallelizing the benchmark suite ${suite} with ${optimizationName}" ;

  # Check if the benchmark suite has been compiled
  if ! test -d benchmarks ; then
    popd &> /dev/null ;
    return ;
  fi

  # Copy the baseline IR 
  make clean &> /dev/null ; 
  make bitcode_copy ;

  echo "Parallelizing benchmarks included in the suite" ;
  benchmarksDir="`pwd`/benchmarks";

  popd &>/dev/null ;

  for bench in `ls ${benchmarksDir}` ; do
    if ! test -d ${benchmarksDir}/${bench} ; then
      continue ;
    fi

    # compile_benchmark $suite $bench ;
    local benchLogFile=$(./bin/submitCondor "${machineName}" "scripts/condor/optimize_benchmark.sh" "'${suite} ${bench} ${optimizationName}'" "output.txt");
    benchLogFiles+=($benchLogFile) ;
  done

  return ;
}



# Fetch the inputs
if test $# -lt 1 ; then
  echo "USAGE: `basename $0` OPTIMIZATION" ;
  exit 1;
fi
optimizationName="$1" ;
machineName="$2" ;
origDir="`pwd`" ;

# Enable NOELLE
source NOELLE/enable ;

# Compile all benchmark suites
compile_suite "PolyBench" ;
# compile_suite "MiBench" ;
# compile_suite "PARSEC3" ;
# compile_suite "NAS" ;
# if ! test -z ${NOELLE_SPEC} ; then
#   compile_suite "SPEC2017" ;
# fi



# Wait until all jobs done
./bin/condorWait ${benchLogFiles[@]} ;

# Copy condor job outputs into output.txt
# Echo of this script is redirected into output.txt, so no need for >>
for benchLogFile in ${benchLogFiles[@]} ; do
  benchOutputFile=${benchLogFile%".log"}.out ;
  cat ${benchOutputFile} ;
done



# Cache the bitcode files
outputDir="${origDir}/results/current_machine" ;

cd ${origDir}/all_benchmark_suites/build ;
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
