#!/bin/bash -e

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

python3 barplotInvariants.py ${repoPath}/results/authors_machine/loops/PARSEC3/invariants.txt ${repoPath}/results/authors_machine/loops/MiBench/invariants.txt ;

