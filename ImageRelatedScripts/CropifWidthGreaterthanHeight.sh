#!/bin/bash
for i in `ls *.JPG`; do
    width=`identify -format "%w" $i`;
    height=`identify -format "%h" $i`;
    if [ $width -gt $height ]; then
#	cp $i temp/$i #we all ready did this
	echo "Crop $i width:$width height:$height"
	convert $i -gravity Center -crop 100x80%+0+0 $i
    fi;
done; 
