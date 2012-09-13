#!/bin/bash
IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
newfilename="blank"
items=`ls *.zip *.rar` #[Zz][Ii][Pp] *.[Rr][Aa][Rr]`
for i in $items
do 
    filename="$i" #${basename "$i"}
    echo $filename
    extension=${filename##*.}
    filename=${filename%.*}
    extension=$( echo ${extension} | tr 'A-Z'  'a-z' )
#    tr 'A-Z' 'a-z' < $extension
    echo $extension
    if [ $extension = "rar" ]
    then 
	newfilename=$filename.cbr
	echo "RAR file!"
    elif [ $extension = "zip" ]
#then it is a zip file
    then 
	newfilename=$filename.cbz
	echo "ZIP file!"
    fi
    echo $newfilename
    mv $i $newfilename
done
