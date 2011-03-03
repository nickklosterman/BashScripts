#!/bin/bash
HrefPageName=$( grep "deviantart.com/art/"  ~/DeviantArt/index.html | sed 's/.*href=\
//' | sed 's/" class=.*//' | sed 's/.*art\///' )

for x in $HrefPageName
do 
echo $x
done