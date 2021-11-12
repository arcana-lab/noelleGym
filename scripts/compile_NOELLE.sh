#!/bin/bash -e

# Download the git repository
if ! test -d NOELLE ; then
  git clone https://github.com/scampanoni/noelle.git NOELLE ;
fi

# Setup the git repository
cd NOELLE ;
make ;
