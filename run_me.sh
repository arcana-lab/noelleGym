#!/bin/bash -e

prefixString="###" ;
echo "${prefixString} This is the artifact evaluation of the NOELLE paper of CGO 2022" ;
echo "${prefixString} We would like to thank you for volunteering for the artifact evaluation, we appreciate it!" ;
echo "${prefixString} All benchmarks from all benchmark suites will be compiled, run, and statistics will be collected" ;
echo "${prefixString} IMPORTANT: results will be stored in `pwd`/results" ;
echo "${prefixString} IMPORTANT: the output of each step will be stored in `pwd`/output.txt (you can run \"tail -f output.txt\" to see the current state)" ;
echo "" ;

# Compile NOELLE
echo "${prefixString} Start compiling NOELLE" ;
./scripts/compile_NOELLE.sh >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE has been compiled succesfully" ;

# Configure NOELLE
source NOELLE/enable ;
export NOELLE_CORES=8 ;

# Compile all benchmarks
echo "${prefixString} Start compiling all benchmarks for all configurations (WARNING: this will take several hours)";
./scripts/compile_benchmarks.sh >> output.txt 2>&1 ;
echo "${prefixString}   All benchmarks have been compiled for all configurations" ;

# Generate statistics about loops
echo "${prefixString} Start generating statistics about loops (this one should less than 30 minutes)" ;
./scripts/loops.sh >> output.txt 2>&1 ;
echo "${prefixString}   All loop statistics are generated" ;

# Generate times of baseline binaries for all benchmarks
echo "${prefixString} Start running baseline binaries (this will take a few hours)";
./scripts/generate_baseline_binaries.sh >> output.txt 2>&1 ;
echo "${prefixString}   Binaries for baseline are generated" ;
./scripts/run_baseline.sh >> output.txt 2>&1 ;
echo "${prefixString}   All baseline binaries are run" ;

# Generate times of DOALL parallelized binaries for all benchmarks
echo "${prefixString} Start running NOELLE DOALL binaries (this will take a few hours)";
./scripts/generate_NOELLE_binaries.sh "DOALL" >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE DOALL binaries are generated" ;
./scripts/run_NOELLE_binaries.sh "DOALL" >> output.txt 2>&1 ;
echo "${prefixString}   All NOELLE DOALL binaries have run" ;

# Generate times of HELIX parallelized binaries for all benchmarks
echo "${prefixString} Start running NOELLE HELIX binaries (this will take a few hours)";
./scripts/optimize_benchmarks.sh "HELIX" >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE HELIX IR files are generated" ;
./scripts/generate_NOELLE_binaries.sh "HELIX" >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE HELIX binaries are generated" ;
./scripts/run_NOELLE_binaries.sh "HELIX" >> output.txt 2>&1 ;
echo "${prefixString}   All NOELLE HELIX binaries have run" ;

# Generate times of DSWP parallelized binaries for all benchmarks
echo "${prefixString} Start running NOELLE DSWP binaries (this will take a few hours)";
./scripts/optimize_benchmarks.sh "DSWP" >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE DSWP IR files are generated" ;
./scripts/generate_NOELLE_binaries.sh "DSWP" >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE DSWP binaries are generated" ;
./scripts/run_NOELLE_binaries.sh "DSWP" >> output.txt 2>&1 ;
echo "${prefixString}   All NOELLE DSWP binaries have run" ;

# Compute the speedups
./scripts/compute_speedups.sh ;
