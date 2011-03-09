#!/bin/bash
IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
newfilename="blank"
items=`ls *.png`
for i in $items
do 
    filename=${i%.*}
    newfilename=${filename}.gif
    convert $i $newfilename
#    rm $i
done
