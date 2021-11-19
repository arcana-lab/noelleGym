#!/bin/bash -e

# Download the git repository
if ! test -d NOELLE ; then
  git clone https://github.com/scampanoni/noelle.git NOELLE ;
fi

# Setup the git repository
cd NOELLE ;
if test -d .gitTemp ; then
  cp -r .gitTemp .git ;
fi
if ! test -e enable ; then
  make ;
fi
