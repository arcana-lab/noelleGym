#!/bin/bash -e

echo $noelleDir ;

noelleBin="`which noelle-config`";
noelleDir=`dirname $noelleBin`/../../ ;
noelleDir=`realpath $noelleDir` ;
if ! test -e Parallelizer_utils.cpp ; then
  ln -s ${noelleDir}/src/core/runtime/Parallelizer_utils.cpp
fi

if ! test -e  NOELLE_APIs.c ; then
  ln -s ${noelleDir}/src/core/runtime/NOELLE_APIs.c
fi
