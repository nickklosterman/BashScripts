#!/bin/bash
for dir in *
do
    if [ -d "$dir" ]
    then
	foldernamept2=${dir%.*}       #the name was screwing stuff up cause the following commands weren't cutting the filename correctly.
	foldernamept1=${foldernamept2%%(*} #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace 
            #foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace
#	    foldername=${foldernamept1//[[:space:]]/-} #<-- this removes all whitespace                   
	    foldername=${foldernamept1//[[:space:]]/-} #<-- this replaces whitespace with a dash
	    #nospaces=${ echo $foldername | tr ' ' '-' }
#There should be no spaces in the images as that was taken care of all ready.
	    echo "$foldername" "$dir"
	    if [ "$foldername" != "$dir" ]
	    then 
		echo "-=$foldername=-"
		mkdir "$foldername"
		mv "$dir" "$foldername"
	#	rm -rf "$dir"
	    fi
    fi
done
