#!/bin/bash
IFS=$(echo -en "\n\b")
shit=`ls *.[Ss]h *.tx i*.[Jj][pP][Gg]`

for i in $shit # `ls *.jpg`
do
filenameandpath=$(basename "$i") #put in quotes or could braek if white space in it
extension=${filenameandpath##*.}
filename=${filenameandpath%.*}
echo $filenameandpath $extension $filename
done