#!/bin/bash -e

echo $noelleDir ;

# Get NOELLE Directory
noelleBin="`which noelle-config`";
noelleDir=`dirname $noelleBin`/../../ ;
noelleDir=`realpath $noelleDir` ;

# Get GINO directory
ginoDir=${noelleDir}/../GINO ;
ginoDir=`realpath $ginoDir` ;

if ! test -e Parallelizer_utils.cpp ; then
  ln -s ${ginoDir}/src/core/runtime/Parallelizer_utils.cpp
fi

if ! test -e  NOELLE_APIs.c ; then
  ln -s ${ginoDir}/src/core/runtime/NOELLE_APIs.c
fi
