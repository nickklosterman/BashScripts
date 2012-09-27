#!/bin/bash
#http://www.commandlinefu.com/commands/view/6310/list-all-file-extensions-in-a-directory
for item in $(ls -Xp | grep -Eo "\.[^./]+$" | sort | uniq)
do
echo -n -e $item '\t'
ls *$item | wc -l 

done
