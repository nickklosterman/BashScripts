#!/bin/bash

#This script will loop  
input="temp.txt"


counter=1500 #lowest in ~6000 range
sentinel=1505 #highest in ~29000 range
while [[ $counter -lt $sentinel ]]
do
url="http://www.silhouetteonlinestore.com/v2/viewShape.aspx?id=$counter"
tempfile="/tmp/silhouette"
tempimagefile="/tmp/silhouetteImages"
#wget "${1}" -O $tempfile
   wget "${url}" -O $tempfile

#method 1 grep "td id=\"mainColumn"  $tempfile | sed 's/^/wget www.silhouetteonlinestore.com/;'
#method 2
   cat $tempfile | sed -n '152p;'| sed 's/.*img src="/http:\/\/silhouetteonlinestore.com/;s/"[ ]*style.*//'  > $tempimagefile
   wget -nc -i  $tempimagefile

let "counter+=1"

done 

