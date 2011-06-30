#!/bin/bash
sqlite3 test.db "select product from Backcountrydeals;" > DatabaseDump.txt
#to tokenize convert all spaces to newlines
#get rid of the lines that are just a dash, also get rid of blank lines
cat DatabaseDump.txt | tr ' ' '\n' | sed 's/^-$//;/^$/d' | sort | uniq -c | sort -n


