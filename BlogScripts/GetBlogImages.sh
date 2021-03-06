#!/bin/bash
#This script was  modified from the one used on Sara Pichelli's blog since this guy used a diff template

#if you don't put the g at the end of the sed command when you want to inserrt newlines you won't split the entire line, you'll only do the first occurrence. no -e out front iether

#this version now takes care of upper and lower case in the file name
#and takes care of jpg and jpeg
#but that isn't really what we want! And it destroys mixed case filenames by converting to lower case when no such file may exist.
#All we really want to do is append a " to the end which is what we now do
sed -e 's/href/\n href/g' $1 | grep s1600 | sed  's/.*href="//g' | sed -e 's/".*/;/' | sed -e 's/1600-h/1600/' | sed -e 's/http/wget -nc -nv "http/' | sed -e 's/.*wget/wget/' | sed 's/$/\"/g' #sed -e 's/.[Jj][Pp]*[Gg].*/.jpg"/' 

#added space when for sed -e 's/".*/;/' 
#for every href replace with a newline then href
#grep on s1600 since the images we want have that in the url
#replace everything up to and including href="  with nothing
#replace everything from the last " to EOL with nothing
#replace 1600-h (the html url) with 1600 (the img url)
#replace everything up to and including the http with the wget command and a quoted http command to capture goofy characters in the url
#append the whole line with a " to close the url quote

commands=$( sed -e 's/href/\n href/g' $1 | grep s1600 | sed  's/.*href="//g' | sed -e 's/".*//' | sed -e 's/1600-h/1600/' | sed -e 's/.*http/wget -nv "http/' | sed 's/$/\";/g') #sed -e 's/.[Jj][Pp]*[Gg].*/.jpg"/' 

#commands=$( sed -e 's/href/\n href/g' $1 | grep s1600 | sed  's/.*href="//g' | sed -e 's/".*//' | sed -e 's/1600-h/1600/' | sed -e 's/http/wget -nc -nv "http/' | sed -e 's/.*wget/wget/' | sed 's/$/\"/g') #sed -e 's/.[Jj][Pp]*[Gg].*/.jpg"/' 

eval $commands

