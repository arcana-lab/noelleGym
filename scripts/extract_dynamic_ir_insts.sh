#!/bin/bash

for i in `ls` ; do
  if ! test -f $i ; then
    continue ;
  fi

  awk -v benchName=$i '
    BEGIN {
      summary=0;
    }{
      if (summary == 0) {
        if ($1 == "Total" && $2 == "statistics"){
          summary = 1;
        }

      } else {
        if ($1 == "Total" &&
            $2 == "number" && 
            $3 == "of" &&
            $4 == "dynamic" && 
            $5 == "IR" &&
            $6 == "instructions" &&
            $7 == "of" && 
            $8 == "program:") {
              dynamic_ir_insts=$9 ;
        }
      }
    } END {
      printf("%s %d\n", benchName, dynamic_ir_insts);
    }' $i ;
done
