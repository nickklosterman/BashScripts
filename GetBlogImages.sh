#!/bin/bash
#This script was  modified from the one used on Sara Pichelli's blog since this guy used a diff template

#if you don't put the g at the end of the sed command when you want to inserrt newlines you won't split the entire line, you'll only do the first occurrence. no -e out front iether

#this version now takes care of upper and lower case in the file name
#and takes care of jpg and jpeg
#but that isn't really what we want! And it destroys mixed case filenames by converting to lower case when no such file may exist.
#All we really want to do is append a " to the end which is what we now do
sed -e 's/href/\n href/g' $1 | grep s1600 | sed  's/.*href="//g' | sed -e 's/".*/;/' | sed -e 's/1600-h/1600/' | sed -e 's/http/wget -nc -nv "http/' | sed -e 's/.*wget/wget/' | sed 's/$/\"/g' #sed -e 's/.[Jj][Pp]*[Gg].*/.jpg"/' 

#added space when for sed -e 's/".*/;/' 
commands=$( sed -e 's/href/\n href/g' $1 | grep s1600 | sed  's/.*href="//g' | sed -e 's/".*//' | sed -e 's/1600-h/1600/' | sed -e 's/http/wget -nc -nv "http/' | sed -e 's/.*wget/wget/' | sed 's/$/\"/g') #sed -e 's/.[Jj][Pp]*[Gg].*/.jpg"/' 

eval $commands

