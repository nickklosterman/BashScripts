#!/bin/bash
IFS=$(echo -en "\n\b")
shit=`ls *.[Mm][Pp]3`

for i in $shit 
do
filenameandpath=$(basename "$i") #put in quotes or could braek if white space in it
extension=${filenameandpath##*.}
filename=${filenameandpath%.*}
echo $filenameandpath $extension $filename
id3v2 -l ${i}
done
