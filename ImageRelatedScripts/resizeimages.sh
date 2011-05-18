#!/bin/bash


for item in 3650 3674 3673 3709 3714 3730 3769 3773 4010 4011 4017 4033 4045 4089 4090 4212 4213 4226
do 
echo resizing IMG_${item}.JPG
convert -resize 800x600 IMG_${item}.JPG IMG_${item}.small.jpg
done