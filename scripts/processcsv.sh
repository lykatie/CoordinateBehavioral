#!/bin/bash

# tail: strip the first 2 lines
# sed: remove parens
# awk: with each line that doesn't start with "!"
#      look at the next line; if next does start with "!"
#      print the next line on same line as current line
#      else print them separately

tail -n +3 $1 | \
sed 's/[()]//g' | \
sed 's/, /,/g' | \
awk '!/^!/ { \
        if((getline n) > 0) { \
            if (n ~ /^!/) { \
                if (NR == 1) \
                    printf("%s%s\n%s",$0,"!Reset",n); \
                printf("\n%s%s",$0,n); } \
            else { printf("\n%s\n%s",$0,n); } } \
        else \
            { printf("\n%s\n",$0); } } \
    /^!/ { printf("%s",$0) }'
