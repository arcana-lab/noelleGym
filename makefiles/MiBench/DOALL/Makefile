# Commands
CC=clang
CPP=clang++

# Arguments
BENCHMARK=
PARALLELIZATION_OPTIONS=-noelle-disable-helix -noelle-disable-dswp
DISABLE_ENABLERS=-noelle-inliner-avoid-hoist-to-main -noelle-disable-whilifier
NOELLE_OPTIONS=-noelle-verbose=3 -noelle-pdg-verbose=1 -noelle-min-hot=1 -noelle-max-cores=12 $(DISABLE_ENABLERS)

all: baseline_parallelized.bc

baseline_with_metadata.bc: 
	./runEnablers.sh $(BENCHMARK) $(NOELLE_OPTIONS)

baseline_parallelized.bc: baseline_with_metadata.bc
	noelle-parallelizer $^ -o $@ $(NOELLE_OPTIONS) $(PARALLELIZATION_OPTIONS)
	llvm-dis $@
	cp $@ $(BENCHMARK).bc

clean:
	rm -rf include/ Parallelizer_utils.* baseline* default.profraw output.prof noelle*.txt *.dot

.PHONY: all clean
