# Commands
CC=clang
CPP=clang++
OPT=opt
OPT_LEVEL=-O3

# Arguments
BENCHMARK=
PARALLELIZATION_OPTIONS=-noelle-disable-helix -noelle-disable-dswp
DISABLE_ENABLERS=-noelle-inliner-avoid-hoist-to-main -noelle-disable-whilifier -noelle-disable-loop-invariant-code-motion -noelle-disable-loop-distribution
NOELLE_OPTIONS=-noelle-verbose=3 -noelle-pdg-verbose=1 -noelle-min-hot=1 -noelle-max-cores=8 $(DISABLE_ENABLERS)

# Front-end
FRONTEND_FLAGS=-emit-llvm -O1 -Xclang -disable-llvm-passes
INCLUDES=-Iinclude/threadpool/include

# Runtime
RUNTIME_DIRNAME="threadpool"
RUNTIME_GITREPO="https://github.com/scampanoni/virgil.git"
RUNTIME_CFLAGS="-DNDEBUG"
RUNTIME=Parallelizer_utils

# Libraries
LIBS=-lm -lstdc++ -lpthread -L../../parsec-3.0/pkgs/apps/x264/inst/amd64-linux.gclang/lib -lx264 -L/usr/lib64 -L/usr/lib

all: baseline_parallelized.bc

baseline.bc: $(BENCHMARK).bc $(RUNTIME).bc
	llvm-link $^ -o $@
	noelle-norm $@ -o $@
	mv $< NOELLE_input.bc

baseline_prof: baseline.bc
	noelle-prof-coverage $^ $@ $(LIBS)

pre.profraw: baseline_prof
	./run.sh $(BENCHMARK) $<
	mv default.profraw $@ 

baseline_pre.bc: pre.profraw baseline.bc
	noelle-meta-prof-embed $^ -o $@
	noelle-pre $@ $(NOELLE_OPTIONS)
	noelle-meta-clean $@ $@
	llvm-dis $@

baseline_pre_prof: baseline_pre.bc
	noelle-prof-coverage $^ $@ $(LIBS)

default.profraw: baseline_pre_prof
	./run.sh $(BENCHMARK) $<

baseline_with_metadata.bc: default.profraw baseline_pre.bc
	noelle-meta-prof-embed $^ -o $@
	noelle-meta-pdg-embed $@ -o $@
	llvm-dis $@

baseline_parallelized.bc: baseline_with_metadata.bc
	noelle-parallelizer $^ -o $@ $(NOELLE_OPTIONS) $(PARALLELIZATION_OPTIONS)
	llvm-dis $@
	cp $@ $(BENCHMARK).bc

$(RUNTIME).bc: $(RUNTIME).cpp download
	$(CPP) $(RUNTIME_CFLAGS) $(INCLUDES) -std=c++17 -emit-llvm $(OPT_LEVEL) -c $< -o $@

$(RUNTIME).cpp:
	./fetchRuntime.sh

download:
	mkdir -p include ; cd include ; ../download.sh $(RUNTIME_GITREPO) $(RUNTIME_DIRNAME) ;

clean:
	rm -rf include/ Parallelizer_utils.* baseline* default.profraw output.prof noelle*.txt *.dot

.PHONY: all clean
