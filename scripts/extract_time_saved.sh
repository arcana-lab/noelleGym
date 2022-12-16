#!/bin/bash

for i in `ls` ; do
  if ! test -f $i ; then
    continue ;
  fi

  awk -v benchName=$i '
    BEGIN {
      
    }{
      if ($1 == "TimeSaved:" && $2 == "Maximum" && $3 == "time" && $4 == "saved" && $5 == "="){
        saved = $6 ;
      }
      if ($1 == "TimeSaved:" && $2 == "Maximum" && $3 == "time" && $4 == "saved" && $5 == "with" && $6 == "DOALL" && $7 == "only" && $8 == "="){
        saved_doall = $9 ;
      }
    } END {
      printf("%s %f %f\n", benchName, saved, saved_doall);
    }' $i ;
done
