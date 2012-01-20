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
    foldername=${i%%(*} #<-- use %% bc want to match longest sequence 
#phail-->${filename##\(*\)}
    echo "$foldername"
#    newfilename=${filename}.gif
#    mogrify -resize 600x800 -equalize -type Grayscale -dither Riemersma -format png *.jpg
#    mogrify -resize 600x800 -equalize -type Grayscale -dither None FloySteinberg -format png *.jpg

    mogrify -resize 600x800 -equalize -type Grayscale -dither None -format png *.jpg
    mkdir "$foldername"
    mv *.png "$foldername"
    rm *.jpg #assume output of unrar/unzip is a set of jpgs
done
