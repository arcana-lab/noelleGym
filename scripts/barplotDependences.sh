#!/bin/bash -e

thisFileAbsolutePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${thisFileAbsolutePath}/.." ;

python3 barplotDependences.py ${repoPath}/results/authors_machine/dependences/PARSEC3/relative_values.txt ${repoPath}/results/authors_machine/dependences/MiBench/relative_values.txt ;

