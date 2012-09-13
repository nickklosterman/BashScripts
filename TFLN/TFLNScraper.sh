#!/bin/bash
TempFile="/tmp/TFLN"
wget -q http://www.textsfromlastnight.com -O "${TempFile}"
#grep "textarea" "${TempFile}" | sed 's/<[^>]*>//g;s/&#39;/\x27/g;s/http.*//g;s/&quot;/\"/g;s/&#45;/-/g;s/&#37;/%/g;'
grep "textarea" "${TempFile}" | recode html | sed 's/<[^>]*>//g;s/http.*//g;s/^[ \t]*//'
#grep "class=\"pagination\"" index.html | sed 's/.*<li class="next"//;'

#this next line gets the last page number 
LastPage=$( grep "class=\"pagination\"" "${TempFile}" | sed 's/.*hellip\; //;s/<\/a>.*//;s/<[^>]*>//g' )

counter=2
while [ "$counter" -lt "$LastPage" ]
do 
wget -q http://www.textsfromlastnight.com/texts/page:${counter} -O "${TempFile}"
#grep "textarea" "${TempFile}" | sed 's/<[^>]*>//g;s/&#39;/\x27/g;s/http.*//g;s/&quot/\"/g;s/&#45/-/g' | grep "&"
grep "textarea" "${TempFile}" | recode html | sed 's/<[^>]*>//g;s/http.*//g;s/^[ \t]*//'
let "counter+=1"
done

if [ -e ${TempFile} ]
then 
rm ${TempFile}
fi