#!/bin/bash
#the input argument should be all the html files from the blog cat'ed together
commands=$( sed 's/http/\nwget --server-response http/g' $1 | grep s1600 | sed 's/\".*/;/' | sed 's/s1600-h/s1600/' )
#eval $commands

#to be used to see which files we missed!
sed  's/http/\nwget http/g' $1 | grep s1600 | sed 's/\".*//' | sed 's/.*\///'