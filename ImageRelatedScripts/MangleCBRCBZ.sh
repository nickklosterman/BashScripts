#!/bin/bash
echo "This is a simple script to automate the Mangle  (Manga-Kindle) app."
echo "Drop the resultant folders into the document folder of the kindle."
IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
newfilename="blank"
items=`ls *.cb[rz]`
for i in $items
do 
    extension=${i##*.}
    if [ "$extension" = "cbr" ]
    then
	echo "CBR file"
	unrar e "$i"
    fi
    if [ "$extension" = "cbz" ]
    then
	echo "CBZ file"
	unzip "$i"
    fi
#    filename=${i%.*}
    foldernamept1=${i%%(*} #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace
    foldername=${foldernamept1/%[[:space:]]/} #<-- this leaves removes the trailing whitespace
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.

#phail-->${filename##\(*\)}
    echo "-$foldername-$foldername2-"
#    newfilename=${filename}.gif
#    mogrify -resize 600x800 -equalize -type Grayscale -dither Riemersma -format png *.jpg
#    mogrify -resize 600x800 -equalize -type Grayscale -dither None FloySteinberg -format png *.jpg

#    mogrify -resize 600x800 -equalize -type Grayscale -dither None -format png *.jpg

    mogrify -resize 800x800 -equalize -type Grayscale -dither None -format png *.jpg
    mkdir "$foldername"
    mv *.png "$foldername"
    rm *.jpg #assume output of unrar/unzip is a set of jpgs
done
