#!/bin/bash
#if you want to upload multiple files than specfy a pattern and use mput instead of put

HOST='djinnius.com'
USER='DailyDeals'

PASSWORD=${1} 
#or use .netrc for password etc
#LocalFilePath=$(readlink -f "${2}" )

#NOTE: the input starred filename needs to be enclosed in quotes or the star will be expanded and you'll only upload the first file of teh expanded list.
#e.g.  not /home/nick/Foo.bar but "/home/nick/Foo.bar"
LocalFilePath=$(dirname "${2}" )
Filename=$(basename "${2}" )
LocalFilePathLength=${#LocalFilePath}
let "LocalFilePathLength+=1"
Filename=${2:$LocalFilePathLength}
#echo "${LocalFilePathA}" "${Filename}"
#we don't need to cd to Deals bc this ftp acct is setup to start off in that directory

ftp -in $HOST <<EOF
user $USER $PASSWORD
lcd "${LocalFilePath}"
binary
mput "${Filename}"
quit
EOF

