#!/bin/bash -e

# Fetch the inputs
if test $# -lt 3 ; then
  echo "USAGE: `basename $0` BENCHMARK IR_FILE \"LINKER_OPTIONS\"" ;
  exit 1;
fi
bench="$1" ;
irFile=$2 ;
LIBS=$3 ;
NOELLE_OPTIONS="${@:4}" ;

# Correctness checks
if ! test -e ${irFile} ; then
  echo "ERROR: the IR file ${irFile} does not exist" ;
  exit 1;
fi

# Fetch the runtime
if ! test -d include ; then
  pushd ./ ;
  mkdir -p include ; 
  cd include ; 
  ../download.sh https://github.com/scampanoni/virgil.git threadpool ;
  popd ;
fi

# Compile the runtime wrapper
if ! test -e Parallelizer_utils.cpp ; then
	./fetchRuntime.sh
fi
if ! test -e Parallelizer_utils.bc ; then
	clang++ -DNDEBUG -Iinclude/threadpool/include -emit-llvm -O3 -c Parallelizer_utils.cpp -o Parallelizer_utils.bc ;
fi

# Check if we have already run the enablers
if test -e baseline_with_metadata.bc ; then
  echo "The IR has already been transformed for enabling parallelization" ;
  exit 0;
fi

# Save the original file
cp ${irFile} NOELLE_input.bc ;

# Normalize
noelle-simplification ${irFile} -o baseline.bc ;

# Profile the code
noelle-prof-coverage baseline.bc baseline_prof ${LIBS}
./run.sh $bench baseline_prof ;
mv default.profraw pre.profraw ;

# Embed the profile into the code
noelle-meta-prof-embed pre.profraw baseline.bc -o baseline_pre.bc ;

# Run the enablers
noelle-pre baseline_pre.bc ${NOELLE_OPTIONS} ;
noelle-meta-clean baseline_pre.bc baseline_pre.bc ;

# Profile the code
noelle-prof-coverage baseline_pre.bc baseline_pre_prof ${LIBS}
./run.sh $bench baseline_pre_prof ;

# Embed the profile into the code
noelle-meta-prof-embed default.profraw baseline_pre.bc -o baseline_with_metadata.bc ;
noelle-meta-pdg-embed baseline_with_metadata.bc -o baseline_with_metadata.bc ;
