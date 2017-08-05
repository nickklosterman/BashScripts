#!/bin/bash

for item in ${1}*
do
    name=${item%.*}
    extension=${item##*.}
    echo "${name} ${extension}"
    convert ${item} -crop 200x220+0+220 ${name}_crop.${extension}
    #if you don't specify a region it'll crawl through the image <geometry> cells at a time creating crop images
done
