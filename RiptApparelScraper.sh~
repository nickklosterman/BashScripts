#!/bin/bash
year=(2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013)
month=(1 2 3 4 5 6 7 8 9 10 11 12)
day=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31)
dateyearstring=`date +%F| cut -c1-4`
datemonthstring=`date +%F| cut -c6-7`
datedaystring=`date +%F| cut -c9-10`

#strip leading zeros so numbers not interpreted as octal
let datedaystring=10#$datedaystring+0
let datemonthstring=10#$datemonthstring+0
#this method didn't work
#datedaystring=${datedaystring/*(0)/}
#datemonthstring=${datemonthstring/*(0)/}
 
echo $dateyearstring $datemonthstring $datedaystring

datemonthstring_formatted=$(printf "%02d" $datemonthstring);
datedaystring_formatted=$(printf "%02d" $datedaystring);
filename=$dateyearstring-$datemonthstring_formatted-$datedaystring_formatted.gif
#filename=$dateyearstring-$datemonthstring-$datedaystring.gif
echo $filename

#elegantly works from the day the script is called and decrements until a file is found (which would signal the last day a comic was successfully downloaded)
while [ ! -f $filename ]; do
#    let "datemonthstring=datemonthstring_formatted"
#    let "datedaystring=datedaystring_formatted'"
    wget http://www.sinfest.net/comikaze/comics/$filename
    let "datedaystring-=1"
#    let "datedaystring-=10#1"
#    let "datedaystring=10#$datedaystring-1"
    if [  $datedaystring -lt 1 ]; then
	let "datedaystring=31"
	let "datemonthstring-=1"
	if [  $datemonthstring -lt 1 ]; then 
	    let "datemonthstring=12"
	    let "dateyearstring-=1"
	fi
    fi
    datemonthstring_formatted=$(printf "%02d" $datemonthstring);
    datedaystring_formatted=$(printf "%02d" $datedaystring);
    filename=$dateyearstring-$datemonthstring_formatted-$datedaystring_formatted.gif
    echo $filename
    
done

feh *.gif &

#this previous method was pretty stupid and not very elegant. It just started at a certain date and hammered away until stopped by the user.
#for i in year
for (( i = 20019 ; i <= 2009 ; i++))
do
# 	for j in month
	for (( j = 10 ; j <= 12 ; j++))
	do
	#	for k in day 
		for (( k = 1 ; k <= 31 ; k++))
		do
		#	if [ month -e 
			 temp_month=$(printf "%02d" $j);
			 temp_day=$(printf "%02d" $k);
			if [ -e $i-$temp_month-$temp_day.gif ];
			then echo File  all ready downloaded!
			else
#				echo wget http://www.sinfest.net/comikaze/comics/$year-$temp_month-$temp_day.gif
				wget http://www.sinfest.net/comikaze/comics/$i-$temp_month-$temp_day.gif
			fi
#k++
#j++
#i++
		done 
	done
done
