#!/bin/bash
echo $1 #this pretty much does what I want but piping it to sed was just simpler this way
FileList=$( ls $1 | sed 's/^/bash \/home\/arch-nicky\/GetBlogImages.sh \"/' | sed 's/$/\" ;/' )
echo $FileList
eval $FileList