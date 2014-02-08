#/bin/bash
speedUpFactor=2
for file in *.mp3; 
do 
    filename=${file%.*} 
    extension=${file##*.}
    ffmpeg -i $file -filter:a "atempo=${speedUpFactor}" -vn ${filename}_SpedUp${speedUpFactor}x.mp3
done
