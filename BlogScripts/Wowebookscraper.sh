#!/bin/bash
echo "
This script took
real    242m9.714s
user    1m30.913s
sys     0m56.397s
on Sun Jan  5 17:39:04 EST 2014
to run through all 1033 pages

the new non adfly urls are sh.st/****

"


outputIntermediaryfile=/tmp/wowAllFrontPageLinks.html
outputIntermediaryImagefile=/tmp/wowAllFrontPageImages.html
outputIndividualLinks=/tmp/wowIndividualPageLinks
individualPagesTogether=/tmp/wowIndividualPagesAllTogether
shortestURLs=/tmp/wowShortestURLs
prefilesURLs=/tmp/wowPrefileURLs
individualBookTitles=/tmp/wowIndividualBookTitles.txt
outputOverviewURLList=/tmp/wowOverviewURLList
wowtemp=/tmp/wowtemp.html
indexfile=/tmp/wow.html

wget -q http://www.wowebook.com -O $indexfile

#create file & output headers:
echo "<html><body>" > $outputIntermediaryfile
echo "<html><body>" > $outputIntermediaryImagefile

#NOTE: removed bc starting at www.wowebook.com/page/1 redirects to www.wowebook.com/ 
#output first page to file
#grep "rel=\"bookmark\"" $indexfile >> $outputIntermediaryfile
#grep "img.wowebook.com" $indexfile >> $outputIntermediaryImagefile


lastpage=$( grep ">\.\.\.<" $indexfile | sed 's/.*page\///g;s/\/.*//' )
echo "last page is $lastpage"

counter=1

#let 'lastpage+=1'
#debug 
lastpage=3

#old inefficient method doing single page downloads
#this downloads one page at a time and processes each one, appending the desired data into the appropriate intermediary file
# while [ $counter -le $lastpage ]
# do 
#     echo -n "$counter "
#     wget -q http://www.wowebook.com/page/$counter -O $wowtemp
#     grep "rel=\"bookmark\"" $wowtemp >> $outputIntermediaryfile
#     grep "img.wowebook.com" $wowtemp | sed 's/<p>//;s/<\/p>//' >> $outputIntermediaryImagefile
#     let 'counter+=1'
# done
#time to execute using this method with lastpage set to 20
# real    2m54.121s
# user    0m2.000s
# sys     0m1.060s
# 2nd time
# real    2m20.589s
# user    0m1.650s
# sys     0m0.770s


#new bulk download method
if [ -e $outputOverviewURLList ]
then 
    echo "removing $outputOverviewURLList"
    rm $outputOverviewURLList
fi
while [ $counter -le $lastpage ]
do 
    echo -n "$counter "
    echo "http://www.wowebook.com/page/$counter" >> $outputOverviewURLList
    let 'counter+=1'
done
if [ -e $wowtemp ]
then
    rm $wowtemp
    touch $wowtemp
else 
    touch $wowtemp
fi
echo "perform parallel download"
cat $outputOverviewURLList | parallel "wget {} -O - >> $wowtemp"
echo "finished performing parallel download"
#perform greps after all 
grep "rel=\"bookmark\"" $wowtemp > $outputIntermediaryfile
grep "img.wowebook.com" $wowtemp | sed 's/<p>//;s/<\/p>//' > $outputIntermediaryImagefile
# real    2m50.118s  # well fuck, it took the same amount of time :(
# user    0m2.207s
# sys     0m1.070s


echo "</body></html>" >> $outputIntermediaryfile
echo "</body></html>" >> $outputIntermediaryImagefile


# I'm not sure why this cmd only pops out 1 and not all individualPageLinks=( $(grep href $outputIntermediaryfile | sed 's/.*href="//;s/".*//') )
grep href $outputIntermediaryfile |  sed 's/.*href="//;s/".*//' > $outputIndividualLinks

#grab all the individual pages in parallel
cat $outputIndividualLinks | parallel "wget {} -O - >> $individualPagesTogether"
#this goes and obtains the shorte.st url. we therefore can skip the 5s wait time
grep "sh.st"  $individualPagesTogether | sed 's/.*href="//;s/".*//' > $shortestURLs

cat $shortestURLs | parallel "wget -U Mozilla  {} -O  - | grep prefiles >> $prefilesURLs" #adding the user agent string gives me the expected behavior; the output isn't as desired, I want to output usable links. I need to use the hold space somehow and append the name to the end and create a link

#cat $shortestURLs | parallel "wget {} -O - >> $prefilesURLs" #this wget call actually gets redirected and doesn't stay on the stupid ad page so I can just snage the prefiles URLs.  The output is really the actual prefiles page.  Lolz without the user agent string shorte.st sends me right to the real page via a 302 redirect.
#cat $shortestURLs | parallel "wget {} -O - | grep prefiles >> $prefilesURLs"
#cat $shortestURLs | parallel "wget {} -O - | grep file_link >> $prefilesURLs"

grep "read-online" $individualPagesTogether | sed 's/.*href="http:\/\/www.wowebook.com\/read-online?q=//;s/".*//' > $individualBookTitles

cat $individualBookTitles
todaysdate=` date +%F `
tar -zvcf wowEbook${todaysdate}.tar.gz /tmp/wow*
