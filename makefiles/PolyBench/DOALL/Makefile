# Commands
CC=clang
CPP=clang++

NOELLE_CORES ?= 12

# Arguments
BENCHMARK=
PARALLELIZATION_OPTIONS=-noelle-disable-helix -noelle-disable-dswp
DISABLE_ENABLERS=-noelle-inliner-avoid-hoist-to-main -noelle-disable-whilifier
NOELLE_OPTIONS=-noelle-verbose=3 -noelle-pdg-verbose=1 -noelle-min-hot=1 -noelle-max-cores=$(NOELLE_CORES) $(DISABLE_ENABLERS)
LIBS=-lm -lstdc++ -lpthread -L/usr/lib64 -L/usr/lib

all: baseline_parallelized.bc

baseline_parallelized.bc:
	./runEnablers.sh $(BENCHMARK) all.bc "$(LIBS)" $(NOELLE_OPTIONS)
	noelle-parallelizer baseline_with_metadata.bc -o $@ $(NOELLE_OPTIONS) $(PARALLELIZATION_OPTIONS)
	cp $@ all.bc

clean:
	rm -rf include/ Parallelizer_utils.* baseline* default.profraw output.prof noelle*.txt *.dot

.PHONY: all clean
