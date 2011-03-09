#!/bin/bash
# argument list 1) date in mdy format 2) path to file folder where file should exist 3) login 4) password
#http://ubuntuforums.org/showthread.php?t=745486 for code to check if file exists
#http://ubuntuforums.org/archive/index.php/t-659624.html looking for way to increment file extension letter

#variables
PASSWORD=HelpOrHinder
LOGIN=nick_klosterman@yahoo.com
extension=.pdf
alf=(a b c d e f g h i j k l m n o p q r s t u v w x y z) #indices start at 0
index=0 #indices start at 0
FILEPATH=$2
date=$1
STOPFLAG=0

#echo ${alf[$index]} #test array index

if [ $# != 1 ];
then echo We need the date as an argument use scriptwget date +%d%m%y to pass it. Use backticks not apostrophes to bracket date and its arguments or you will pass just the words date etc. We also need the path to the directory
else

	filename=eibd$date$extension #for some reason eibd$datea.pdf wouldn't produce e.g. eibd040908a.pdf
	echo Initially trying to get $filename.

	if [ -e /home/min/a/nkloster/$filename ];
#	if [ -e $FILEPATH$filename ];
		then echo File $filename all ready downloaded!
	else
		
		#eval wget http://eibd.investors.com/pdfibd/$filename --http-use=$LOGIN --http-passwd=$PASSWORD
		wget http://eibd.investors.com/pdfibd/$filename --http-use=$LOGIN --http-passwd=$PASSWORD
		echo eval wget http://eibd.investors.com/pdfibd/$filename --http-use=$LOGIN --http-passwd=$PASSWORD
 #to check if file exists perform "ls *.pdf | grep eibd$date.pdf"
 #echo ls *.pdf | grep eibd$date.pdf > /dev/null || echo wget http://eibd.investors.com/pdfibd/eibd$datea.pdf 
 #--http-use=nick_klosterman@yahoo.com --http-passwd=HelpOrHinder
 #echo ls *.pdf | grep eibd$date.pdf > /dev/null || echo file not present
 #if file doesn't exist then increment to a b c d 


#need a while loop to check if the file exists and to keep checking for it otherwise
		while [ ! -e /home/nicky/$filename ] && [ $STOPFLAG -ne 1 ]
		do
			filename=eibd$date${alf[$index]}$extension
			echo $filename
			let "index += 1" 
# $index+1 #increment index and plop in letter to filename mechanism index=$index+1 #increment index and plop in letter to filename mechanism
			wget http://eibd.investors.com/pdfibd/$filename --http-use=$LOGIN --http-passwd=$PASSWORD
		
			if [ $index -ge 26 ];
			then STOPFLAG=1
			fi
		done

	fi
fi

#this works but isn't as elegant as the loop.
#if [ -f /home/nicky/$filename ];
#then
#echo /home/nicky/$filename file exists
#else
#extension1=a.pdf
#filename=eibd$date$extension1
#echo $filename
#eval wget http://eibd.investors.com/pdfibd/$filename.pdf --http-use=nick_klosterman@yahoo.com --http-passwd=HelpOrHinder
#echo ls *.pdf | grep eibd$date.pdf > /dev/null || FLAG=2
#fi

