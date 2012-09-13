#!/bin/bash

echo "This script touches nonexistent files that are listed in the specified direcotiries Files.txt2 file.\n The script should be executed in the parent directory of the directories you are specifying. \n i.e. Run the script in the DeviantArt folder for Artist1 Artist2 etc."

Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: TouchDirFileListSpecifyDirectories.sh dir <dir> ..."
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments                                                                      
    do
	
	echo $1
	cd "$1"
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
shift #shift to get next command line argument 
    done
fi