#!/bin/bash
if [ $# -ne 1 ]
then 
echo "Give a file as an argument which we will perform the operation on."
else
    cat ${1} | tr ' ' '\n' | sed 's/-//g;/^$/d;' | sort | uniq -c  | sort -g
#change all spaces into newlines to tokenize the words, remove the dashes, remove lines that are empty, sort alphabetically, perform a uniq count, sort numerically
fi