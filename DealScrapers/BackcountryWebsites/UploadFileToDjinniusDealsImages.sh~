#!/bin/bash
#if you want to upload multiple files than specfy a pattern and use mput instead of put

HOST='djinnius.com'
USER='DailyDeals'

PASSWORD=${1} 
#or use .netrc for password etc
#LocalFilePath=$(readlink -f "${2}" )
LocalFilePath=$(dirname "${2}" )
Filename=$(basename "${2}" )

#we don't need to cd to Deals bc this ftp acct is setup to start off in that directory

ftp -in $HOST <<EOF
user $USER $PASSWORD
lcd "${LocalFilePath}"
binary
put "${Filename}"
quit
EOF