#!/bin/bash
counter=1
cdn_number=1
while [ $counter -lt 617 ]
do
imagenum=$(printf "%03d" $counter);
echo $imagenum
echo $cdn_number
let "counter+=1"
let "cdn_number+=1"
feh http://$cdn_number.cdn.ddstatic.com/digitaldesire/bp-content/tour/dailyphoto/$imagenum/idx-1024-jpg.jpg
#wget  http://$cdn_number.cdn.ddstatic.com/digitaldesire/bp-content/tour/dailyphoto/$imagenum/idx-1024-jpg.jpg
if [ $cdn_number -gt 2 ]
then
cdn_number=0
fi
done