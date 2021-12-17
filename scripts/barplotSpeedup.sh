#!/bin/bash -e

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

python3 barplotSpeedup.py ${repoPath}/results/authors_machine/time/PARSEC3/DOALL.txt ${repoPath}/results/authors_machine/time/PARSEC3/HELIX.txt ${repoPath}/results/authors_machine/time/PARSEC3/DSWP.txt ${repoPath}/results/authors_machine/time/PARSEC3/gcc.txt ${repoPath}/results/authors_machine/time/PARSEC3/gcc-par.txt ${repoPath}/results/authors_machine/time/PARSEC3/icc.txt ${repoPath}/results/authors_machine/time/PARSEC3/icc-par.txt ${repoPath}/results/authors_machine/time/MiBench/DOALL.txt ${repoPath}/results/authors_machine/time/MiBench/HELIX.txt ${repoPath}/results/authors_machine/time/MiBench/DSWP.txt ${repoPath}/results/authors_machine/time/MiBench/gcc.txt ${repoPath}/results/authors_machine/time/MiBench/gcc-par.txt ${repoPath}/results/authors_machine/time/MiBench/icc.txt ${repoPath}/results/authors_machine/time/MiBench/icc-par.txt ;

