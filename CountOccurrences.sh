#!/bin/bash
if [ $# -ne 1 ]
then 
echo "Give a file as an argument which we will perform the operation on."
else
sort ${1} | sed '/^$/d'| uniq -c  | sort -g
fi