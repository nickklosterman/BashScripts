#!/bin/bash

echo "this should be used to create a list of files that can be used to prevent downloading undesirable image files.  If run multiple times then would proly want to sort and uniq the file list so that aren't doing a lot of work."

find -type d -name '*' | while read name ; do
    echo $name
    cd "$name"
    #echo "Shouldve changed dirs to:"
    #pwd
    DirFile=${name}Files.txt2
    echo $DirFile
    if [ 1 -eq 1 ] 
    then
shopt -s nullglob #if there are no files with an extension then file will be set to *.*, setting this option prevents that behavior
	for file in *.*
	do
	    echo $file >> Files.txt2 
#$DirFile 
	    
	done
    fi
    cd $OLDPWD
    #echo "should've backed down to Devart"
    #pwd
done

if [ 0 -eq 1 ]
then
for name in *.jpg
do
echo $name >> jpgfilelist.txt
done
fi

#http://www.linuxquestions.org/questions/programming-9/bash-ls-for-loops-and-whitespaces-in-directories-126388/page2.html