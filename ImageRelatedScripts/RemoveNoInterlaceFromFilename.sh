#!/bin/bash

IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.

echo "This program will remove the nointerlace suffix put on filenames by the MogrifyforDigitalPictureFrame.sh script"

newfilename="blank"
items=`ls *`
for i in $items
do 
    filename=${i%.*}
    extension=( ` echo "${i}" | sed 's/.*\./\./'` ) #just get file extension. Pretty sure there is an easier way such as for getting just the filename
    filename=( `echo "${filename}" |  sed 's/nointerlace//'  `)
    newfilename=${filename}${extension}

#echo ${filename}
#echo ${extension}
#echo ${newfilename}
mv $i $newfilename
done
