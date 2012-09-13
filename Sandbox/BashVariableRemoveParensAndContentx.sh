#!/bin/bash

function convertFoldername()
{   
    i="${1}"
#    echo "inmakestuff=$i" # why aren't we getting anything
    IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.

    foldernamept2=${i%.*}       #the name was screwing stuff up cause the following commands weren't cutting the filename correctly.
    foldernamept1=${foldernamept2%%(*}   #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace
        #foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace
        foldername=${foldernamept1//[[:space:]]} #<-- this removes the all whitespace
        foldernamenospace=${foldername//[[:punct:]]} # echo "$foldername" | tr '[:punct:]' '_' }
#remove the # sign in filenames for the images
        echo $foldernamenospace
    }



item="${1}"

bob=${item//[[:punct:]]} 
bobo=${item//#} #it appears that # is in the :punct: space

boo=${item/([^)]*)} #this line and the line below are equivalent
booo=$( echo $item | sed 's/([^)]*)//g' )
#echo $bob----====----$bobo+=+$boo
echo $boo+=+ $booo
