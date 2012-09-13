#!/bin/bash
counter=1
while [ $counter -lt 150 ]
do 
filename=$(printf "%03d" $counter)
filename=${filename}.jpg
echo $filename 
wget http://www.mitografia.com/krimages/${filename}
let counter+=1
done
