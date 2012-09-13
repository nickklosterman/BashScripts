#!/bin/bash
File="${1}"
Data=`cat "${File}" | tr '{' '\n' | sed 's/^.*"http/http/g;s/[^"]*"//g'`
cat "${File}" | tr '{' '\n' | sed 's/^.*"http/\nhttp/g;s/".*//' | grep http | sort | uniq
#cat ${File} | sed 's/^.*http/\nhttp/g' # | grep http #;s/[^"]*"//g'


