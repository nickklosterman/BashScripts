#!/bin/bash

echo "this should be used to create a list of files that can be used to prevent downloading undesirable image files.  If run multiple times then would proly want to sort and uniq the file list so that aren't doing a lot of work."

find -type d -name '*' | while read name ; do
    echo $name
    cd "$name"
    #echo "Shouldve changed dirs to:"
    #pwd
    DirFile=Files.txt2 #${name}Files.txt2
    echo $DirFile

    while read Line
    do 
	if [ ! -e $Line ] #only touch non-existent files
	then
	    echo "touching $Line"
	    touch $Line
	fi
    done < $DirFile
    

    cd $OLDPWD
    #echo "should've backed down to Devart"
    #pwd
done
