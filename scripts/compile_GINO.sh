#!/bin/bash -e

# Enable NOELLE
source external/NOELLE/enable ;

# Go to the directory where we install all external software
mkdir -p external ;
cd external ;

# Download the git repository
if ! test -d GINO ; then
  git clone https://github.com/arcana-lab/gino.git GINO ;
fi

# Compile GINO 
cd GINO ;
if ! test -e enable ; then
  make ;
  make clean ;
fi
