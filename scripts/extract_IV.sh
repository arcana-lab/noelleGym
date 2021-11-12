#!/bin/bash

for i in `ls` ; do
  if ! test -f $i ; then
    continue ;
  fi

  awk -v benchName=$i '
    BEGIN {
      summary=0;
      noelle=1 ;
    }{
      if (summary == 0){
        if ($1 == "Total" && $2 == "statistics"){
          summary = 1;
        }

      } else {
        if ($1 == "Number" && $2 == "of" && $3 == "IVs:"){
          if (noelle){
            noelleIVs=$4 ;
            noelle=0; 
          } else {
            llvmIVs=$4 ;
          }
        }
      }
    } END {
      printf("%s %d %d\n", benchName, llvmIVs, noelleIVs);
    }' $i ;
done
