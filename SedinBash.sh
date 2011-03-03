#!/bin/bash
for items in `ls *.png`
do 
filename=${items%.*}
filename2=( `echo "${filename}" |  sed 's/_by_/SHIT/'`  )
echo $filename
echo $filename2
done