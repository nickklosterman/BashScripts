#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
NumberOfExpectedArguments=10
NumberOfImages=310

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number of comics to grab"
else 
    counter=$NumberOfImages
    filelist=""
    while [ $counter -ge 0 ]; do
	wget http://www.delilahdirk.com/content/?p=${counter} -O - >> /tmp/delilahdirk
	echo ${counter}
	let "counter-=1"
    done
fi

grep "img src" /tmp/delilahdirk | grep ddattl | sed 's/.*<img src="/wget /;s/".*//' > /tmp/delilahdirkcomicimages


while read LINE
do
#    echo $LINE
    exec $LINE & #without this backgroudn we only get one image.
    sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
done < /tmp/delilahdirkcomicimages

sleep 10s

rename prl ch0 ddattl*  #rename the files so that the prelude comes before the chapter files. 
zip DelilahDirkAndTheTurkishLieutenant ddattl*.jpg
mv DelilahDirkAndTheTurkishLieutenant.zip DelilahDirkAndTheTurkishLieutenant.cbz
evince DelilahDirkAndTheTurkishLieutenant.cbz


