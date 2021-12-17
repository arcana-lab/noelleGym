#!/bin/bash -e

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

python3 barplotInductionVariables.py ${repoPath}/results/authors_machine/loops/PARSEC3/induction_variables.txt ${repoPath}/results/authors_machine/loops/MiBench/induction_variables.txt ;

