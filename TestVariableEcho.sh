#!/bin/bash
filelisting=`ls -alch *.txt`
shtuff=`cat Data.txt`
duo=$filelisting$shtuff
#echo "${duo}"

NumRecordsToDisplay=${1}
databaseoutput=`sqlite3 -html /home/nicolae/Desktop/sqlite_examples/test.db  "select * from Backcountrydeals where websitecode=1 order by Bkey desc limit ${NumRecordsToDisplay}"`
databaseoutput=`sqlite3 ~/Desktop/sqlite_examples/test.db "select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=1 order by Bkey desc limit 10"`
echo ${databaseoutput}