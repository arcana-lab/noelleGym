# Commands
CC=clang
CPP=clang++

NOELLE_CORES ?= 12

# Arguments
BENCHMARK=
PARALLELIZATION_OPTIONS=-noelle-disable-helix -noelle-disable-dswp -noelle-disable-doall
DISABLE_ENABLERS=-noelle-inliner-avoid-hoist-to-main -noelle-disable-whilifier
NOELLE_OPTIONS=-noelle-verbose=3 -noelle-pdg-verbose=1 -noelle-min-hot=1 -noelle-max-cores=$(NOELLE_CORES) $(DISABLE_ENABLERS)
LIBS=-lm -lstdc++ -lpthread -ltermcap

all: baseline_parallelized.bc O3_with_metadata.bc

O3.bc: all.bc
	opt -O3 $< -o $@

O3_prof: O3.bc
	noelle-prof-coverage $< $@ $(LIBS)

O3.profraw: O3_prof
	./run.sh $(BENCHMARK) $<

O3_with_metadata.bc: O3.profraw O3.bc
	noelle-meta-prof-embed $^ -o $@
	noelle-meta-loop-embed $@ -o $@
	llvm-dis $@

baseline_parallelized.bc:
	./runEnablers.sh $(BENCHMARK) $(BENCHMARK).bc "$(LIBS)" $(NOELLE_OPTIONS)
	noelle-parallelizer baseline_with_metadata.bc -o $@ $(NOELLE_OPTIONS) $(PARALLELIZATION_OPTIONS)
	cp $@ $(BENCHMARK).bc

clean:
	rm -rf include/ Parallelizer_utils.* baseline* default.profraw output.prof noelle*.txt *.dot

.PHONY: all clean
