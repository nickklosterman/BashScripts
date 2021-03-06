#!/bin/bash
#if you want to upload multiple files then specify a pattern and use mput instead of put

HOST='djinnius.com'
USER=${1}
PASSWORD=${2} 

#or use .netrc for password etc
#LocalFilePath=$(readlink -f "${2}" )
LocalFilePath=$(dirname "${3}" )
Filename=$(basename "${3}" )

#we don't need to cd to Deals bc this ftp acct is setup to start off in that directory

ftp -in $HOST <<EOF
user $USER $PASSWORD
lcd "${LocalFilePath}"
binary
put "${Filename}"
quit
EOF
