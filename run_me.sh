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

# Generate times of parallelized binaries for all benchmarks
echo "${prefixString} Start running NOELLE binaries (this will take a few hours)";
./scripts/generate_NOELLE_binaries.sh >> output.txt 2>&1 ;
echo "${prefixString}   NOELLE binaries are generated" ;
./scripts/run_NOELLE_binaries.sh >> output.txt 2>&1 ;
echo "${prefixString}   All NOELLE binaries are run" ;
