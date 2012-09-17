#!/bin/bash
TEMP="/tmp/flickrpage"
SUBTEMP="/tmp/subflickrpage"
IMAGEPAGETEMP="\/tmp\/flickrimagepage" #if you don't escape the slashes then when it gets expanded in a double dquoted sed string it'll make sed barf. However you then can't use the $ in that expansion to mean the EOL.  

#for sed if you want to expand a variable you need to use double quotes for the sed string and not single quotes. yet there are consequences to doing this 

IMAGEPAGETEMP_="/tmp/flickrimagepage" 

#get first page of gallery
counter=1 #could do start stop numbering
if [ 1 -eq 1 ]
then
    while [[ $counter -le $2 ]]
    do
	wget $1/page$counter -O - >> $TEMP  #the -O - let wget send output to stdout which can then be all capture via piping to act like the appenc command
	let 'counter+=1'
    done
fi

#scrape page for links to subpages containing images

grep pc_img $TEMP | sed  's/^.*href="/wget "http:\/\/www.flickr.com/;s/m\".*/m\" -O - >> /;s/in/sizes\/o\/in/;'| sed "s/ >> / >> $IMAGEPAGETEMP/"  > $SUBTEMP

#cat $TEMP |  sed -e 's/m\".*/m\" -O - >> '"$IMAGEPAGETEMP" '/'  
#cat $TEMP |  sed -e 's/photostream\".*/m\" -O - >> /;s/^/"$IMAGEPAGETEMP"/  ' this didn't work because I hadn't escaped the / with \/ in the filename and path


bash $SUBTEMP
#scrape subpage for original size image
grep "Original size" -B 1 $IMAGEPAGETEMP_ | grep farm[0-9].staticflickr | sed 's/.*"http:/wget "http:/;s/">/"/' > $TEMP

bash $TEMP
