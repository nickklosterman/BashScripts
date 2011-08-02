#!/bin/bash


function ConvertForwardSlashToBackSlash() 
{
#the apostrophe for possessives screws things up so we need to convert it and then convert it back                               
#Output=` echo "${1}" | sed 's/\x27/\^/g'`
#Output2=` echo "${Output}" | sed 's/\//\\/' `
Output3=`echo "${1}" | tr '/' '\\' `
# s/\^/\x27/g' `
#stuff="mi/ke's"; echo ${stuff} | sed 's/\x27/\^/;s/\//\\/;s/\^/\x27/' # this works so what is up with the line above? ....uggggh cuz we weren't copying it over to the directory where we were executing the script!!!                                                                                                  
echo ${Output3}
}

mike="st//''s[["
#echo "${mike}" | sed 's/\x27/\^/g; s/\//\\/g; s/\^/\x27/g' 
ConvertForwardSlashToBackSlash "${mike}"
Product="XCEL 2/3mm wetsuit"

 echo "beforeslash $Product"
        Filename2=$( ConvertForwardSlashToBackSlash "${Product}").jpg #this takes care of the only forbidden character for filenames the '/' since that is i\nterpreted as a directory separator                                                              

        Filename=${Product}.jpg
        echo "slash converted filename:${Filename2}: unconverted:${Filename}:"
        echo "afterslash $Filename"
        echo "prod:${Product}: filename:${Filename}:"
