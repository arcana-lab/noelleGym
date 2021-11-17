#!/bin/bash

for i in `ls` ; do
  if ! test -f $i ; then
    continue ;
  fi

  awk -v benchName=$i '
    {

      if ($1 == "Number" && $2 == "of" && $3 == "potential" && $4 == "memory" && $5 == "dependences:"){
        printf("%d\n", $6);
        exit ;
      }
    }' $i ;
done
