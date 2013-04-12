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

# http://feeds.feedburner.com/tfln http://www.textsfromlastnight.com/texts/page:3

# I need to stop the download after I've encountered the text from the first line of an input file. Ideally the input file would be the output from the previous run of TFLN.
# on the command line we'd specify the previous TFLN output file, the program would grab the first line (head -n 1 file.txt) and compare the incoming stream of data. 
# It would then stop the download once the search text was encountered.
# It would then remove all lines after the found line from the output stream. ( awk '/^SearchString/{exit}1' tempfile.txt from http://stackoverflow.com/questions/1946363/how-do-i-display-data-from-the-beginning-of-a-file-until-the-first-occurence-of  there are also solutions using sed in there as well. )
# The tempfile would then be cated with the previous input file to produce the updated output file without any duplicate lines. 
# I had been looking into 'comm' to solve the problem but the above pseudo code is more elegant and less hackish
 
