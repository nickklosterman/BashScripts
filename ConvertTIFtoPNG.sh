#!/bin/bash
IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
newfilename="blank"
items=`ls *.tif`
for i in $items
do 
    filename=${i%.*}
    newfilename=${filename}.png
    convert $i $newfilename
#    rm $i
done
