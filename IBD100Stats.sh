#!/bin/bash
#requires that two directories be provided.
#will then remove any file from directory X that isn't also in directory Y
#Originally written for a image directory and a thumbnail directory (as a child directory for simplicity). Allowed quickly going through the thumbnail directory and selecting files for deletion. Then having the deleted files from the thumbnail direcotry mirrored in the parent directory as well.
#the files in both directories should be named the same  for this to work. So create a thumbnail directory. copy all files into the thumbnail directory, then run mogrify on the files to create thumbnails.

#get list of all stock symbols
#get current quote of all stock symbols
#compare current quote to past quote when on IBD100 List
# loop over mysql output
# grep appropriate line in quote file
# parse out price
# perform math calc using bc
# printout comparison line by line

if [ $# -lt 0 ]
then
    echo "Please provide a list of Two directories are needed for execution of this script."
    echo "Files from TargetPath that aren't in ThumbnailPath will be deleted."
    echo "scriptname.sh TargetPath ThumbnailPath"
else
    mysql --skip-column-names -s --database StockMarketData -e "select distinct symbol from IBD100 order by symbol asc" -p > /tmp/IBD100stocks.txt
stocklist=$(cat /tmp/IBD100stocks.txt | tr "\n" "+" )
	wget "http://download.finance.yahoo.com/d/quotes.csv?s=${stocklist}&f=sl1&e=csv" -O /tmp/quotes.csv -nv

	cat /tmp/quotes.csv

while read Line
do
#echo ${Line}
symbol=$( echo ${Line} | cut -d "," -f 1  )
mostrecentclosingprice=$( echo ${Line} | cut -d "," -f 2  )
#min,max()
query="select avg(ClosingPrice) from IBD100 where Symbol=${symbol}";
echo ${symbol} ${mostrecentclosingprice}
echo ${query}
done < /tmp/quotes.csv

#http://www.gummy-stuff.org/Yahoo-data.htm or put in spreadsheet and do it that way
#http://www.gummy-stuff.org/SP500-stuff.htm	
#    done
    
fi