#!/bin/bash

echo "this should be used to create a list of files that can be used to prevent downloading undesirable image files.  If run multiple times then would proly want to sort and uniq the file list so that aren't doing a lot of work."

find -type d -name '*' | while read name ; do
    echo $name
    cd "$name"

    pwd
    fdupes . 
    
    echo "---------------------"
    cd $OLDPWD

done
