#!/bin/bash
for x in "$@" #this will handle quoted args with spaces in them, wo the dbl quotes it won't work tho
do 
echo $x
done
#man -P "less -p 'Expands  to  the positional'" bash