#!/bin/bash -e

# Get path to this file
THIS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" ;
repoPath="${THIS_PATH}/.." ;

# Setup the python virtual environment for noelleGym
virtualEnvDir="${repoPath}/pythonVirtualEnv" ;
if ! test -d ${virtualEnvDir} ; then
    mkdir ${virtualEnvDir} ;

    virtualenv -p python3 ${virtualEnvDir} ;

    source ${virtualEnvDir}/bin/activate ;

    pip install --upgrade pip ;

    pip install matplotlib ;
    pip install numpy ;

else
  source ${virtualEnvDir}/bin/activate ;
fi
