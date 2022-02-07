# Commands
CC=clang
CPP=clang++

# Arguments
BENCHMARK=
PARALLELIZATION_OPTIONS=-noelle-disable-helix -noelle-disable-dswp
DISABLE_ENABLERS=-noelle-inliner-avoid-hoist-to-main -noelle-disable-whilifier
NOELLE_OPTIONS=-noelle-verbose=3 -noelle-pdg-verbose=1 -noelle-min-hot=1 -noelle-max-cores=12 $(DISABLE_ENABLERS)
LIBS=-lm -lstdc++ -lpthread -L/usr/lib64 -L/usr/lib

all: baseline_parallelized.bc

baseline_with_metadata.bc:
	./runEnablers.sh $(BENCHMARK) all.bc "$(LIBS)" $(NOELLE_OPTIONS)

baseline_parallelized.bc: baseline_with_metadata.bc
	noelle-parallelizer $^ -o $@ $(NOELLE_OPTIONS) $(PARALLELIZATION_OPTIONS)
	llvm-dis $@
	cp $@ all.bc

clean:
	rm -rf include/ Parallelizer_utils.* baseline* default.profraw output.prof noelle*.txt *.dot

.PHONY: all clean
