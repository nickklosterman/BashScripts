#!/bin/bash
TempFile="/tmp/TFLNparallel"

download_and_reformat() 
{
    TempFile=$2
    counter=$1

    #this method you grep after each webpage
    #wget -q http://www.textsfromlastnight.com/texts/page:${counter} -O "${TempFile}" 
    #grep "textarea" "${TempFile}" | recode html | sed 's/<[^>]*>//g;s/http.*//g;s/^[ \t]*//'

    #this method we parallelize the wget part and later on after all pages are downloaded we Grep. line 36
    wget -q http://www.textsfromlastnight.com/texts/page:${counter} -O - >> "${TempFile}"
#    echo $1

}
export -f download_and_reformat

#wget url -O - >> file
wget -q http://www.textsfromlastnight.com -O "${TempFile}"

grep "textarea" "${TempFile}" | recode html | sed 's/<[^>]*>//g;s/http.*//g;s/^[ \t]*//'


#this next line gets the last page number 
LastPage=$( grep "class=\"pagination\"" "${TempFile}" | sed 's/.*hellip\; //;s/<\/a>.*//;s/<[^>]*>//g' )


#seq $LastPage | parallel wget -q http://www.textsfromlastnight.com/texts/page:{} -O "${TempFile}"

#seq 2 $LastPage #| parallel $(download_and_reformat {})

parallel download_and_reformat ::: $(seq 2 $LastPage) ::: $TempFile

grep "textarea" "${TempFile}" | recode html | sed 's/<[^>]*>//g;s/http.*//g;s/^[ \t]*//'

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
 
