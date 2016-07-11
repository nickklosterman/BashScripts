#!/bin/bash

for item in *.1 *.2 *.3 *.4 *.5 *.6
do
    newFilename=${item%.*}
    echo "Moving ${item} to ${newFilename}"
    mv ${item} ${newFilename}
done
