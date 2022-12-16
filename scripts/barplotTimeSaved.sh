#!/bin/bash -e

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

python3 barplotTimeSaved.py ${repoPath}/results/current_machine/time_saved/PARSEC3/time_saved.txt ${repoPath}/results/current_machine/time_saved/MiBench/time_saved.txt ${repoPath}/results/current_machine/time_saved/NAS/time_saved.txt ${repoPath}/results/current_machine/time_saved/PolyBench/time_saved.txt ;

