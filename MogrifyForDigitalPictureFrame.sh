#!/bin/bash

IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.

echo "This program will delete gifs and pngs in the conversion process."
echo "Only run this on a directory on a flashdrive after copying the files."
echo "You have 5 seconds to cancel this before the process will commence."
#echo "I think this was somehow going into the directories because of the 'ls *' instead of the ls *.* which I have now"

sleep 5s

newfilename="blank"
items=`ls *.*`
for i in $items
do 
    mogrify -resize 800x600 $i 
done



#convert all the gifs to non-interlaced gifs since the photoframe doesn't handle interlacing
newfilename="blank"
items=`ls *.[Gg][Ii][Ff]`
for i in $items
do 
    filename=${i%.*}
    newfilename=${filename}nointerlace.gif
    convert $i -interlace none $newfilename
    rm $i
done

#convert all the pngs to gifs since teh photoframe doesn't handle pngs
newfilename="blank"
items=`ls *.[Pp][Nn][Gg]`
for i in $items
do 
    filename=${i%.*}
    newfilename=${filename}.gif
    convert $i -interlace none $newfilename
    rm $i
done

#convert to non-progressive jpgs
newfilename="blank"
items=`ls *.[Jj][Pp][Gg]`
for i in $items
do 
    filename=${i%.*}
    newfilename=${filename}nointerlace.jpg
    convert $i -interlace none $newfilename
    rm $i
done
