#!/bin/bash

for i in `ls` ; do
  if ! test -f $i ; then
    continue ;
  fi

  awk -v benchName=$i '
    {
      if ($1 == "Number" && $2 == "of" && $3 == "memory" && $4 == "dependences:"){
        printf("%d\n", $5);
        exit ;
      }
    }' $i ;
done
