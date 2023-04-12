# Commands
CC=clang
CPP=clang++

NOELLE_CORES ?= 12

# Arguments
BENCHMARK=
PARALLELIZATION_OPTIONS=-noelle-disable-helix -noelle-disable-dswp -noelle-disable-doall
DISABLE_ENABLERS=-noelle-inliner-avoid-hoist-to-main -noelle-disable-whilifier
NOELLE_OPTIONS=-noelle-nondeterministic-prvgs -noelle-verbose=3 -noelle-pdg-verbose=1 -noelle-min-hot=1 -noelle-max-cores=$(NOELLE_CORES) $(DISABLE_ENABLERS)
LIBS=-lm -lstdc++ -lpthread -L../../parsec-3.0/pkgs/apps/x264/inst/amd64-linux.gclang/lib -lx264 -L/usr/lib64 -L/usr/lib
PROFILE_INPUT=simlarge

include ./Makefile.common

