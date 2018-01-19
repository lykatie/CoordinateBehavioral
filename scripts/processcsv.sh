#!/bin/bash

# tail: strip the first 2 lines
# sed: remove parens
# awk: with each line that doesn't start with "!"
#      look at the next line; if next does start with "!"
#      print the next line on same line as current line
#      else print them separately
for filename in ../data_raw/*.csv; do
    echo -n "Processing "
    echo $(basename $filename)
#    echo "time,x,z,y,jx,jy,wx,wy,wz,event" > ../data_processed/$(basename $filename)
    tail -n +3 $filename | \
    sed 's/[()]//g' | \
    sed 's/, /,/g' | \
    gawk '!/^!/ { \
            if((getline n) > 0) { \
                if (n ~ /^!/) { \
                    if (NR == 1) \
                        printf("%s%s\n%s",$0,"!Reset",n); \
                    printf("\n%s%s",$0,n); } \
                else { printf("\n%s\n%s",$0,n); } } \
            else \
                { printf("\n%s\n",$0); } } \
                    /^!/ { printf("%s",$0) }' | \
    tail -n +2 > ../data_processed/$(basename $filename)
    # need final \r\n to process in matlab textscan
    echo >> ../data_processed/$(basename $filename)
done
