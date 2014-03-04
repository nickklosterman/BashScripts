#/bin/bash

speedUpFactor=1.5  #dman it just write a front end script that calls this one with the first param as the speedup factor.
for file in *.mp3; 
do 
    filename=${file%.*} 
    extension=${file##*.}
    ffmpeg -i $file -filter:a "atempo=${speedUpFactor}" -vn ${filename}_SpedUp${speedUpFactor}x.mp3
done
