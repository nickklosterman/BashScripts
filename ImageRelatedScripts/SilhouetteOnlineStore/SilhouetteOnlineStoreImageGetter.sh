#!/bin/bash

#read file
 
input="temp.txt"

while read line 
do
tempfile="/tmp/silhouette"
tempimagefile="/tmp/silhouetteImages"
#wget "${1}" -O $tempfile
wget "${line}" -O $tempfile

#method 1 grep "td id=\"mainColumn"  $tempfile | sed 's/^/wget www.silhouetteonlinestore.com/;'
#method 2
cat $tempfile | sed -n '152p;'| sed 's/.*img src="/http:\/\/silhouetteonlinestore.com/;s/"[ ]*style.*//'  > $tempimagefile
wget -nc -i  $tempimagefile
done < $input 

