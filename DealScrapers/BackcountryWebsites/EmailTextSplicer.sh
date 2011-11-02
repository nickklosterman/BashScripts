#!/bin/bash

echo "This script was used to create the pull down menu from the list of providers at www.emailtextmessages.com"

#list from www.emailtextmessages.com

#remove html tags, remove text(not necessary for 1st file since when we print every other line we don't print those), remove leading whitespace, remove blank lines
# the sed -n X~Y prints every Y line starting at line X
egrep -i "ul>|h3>|li>" emailtextmessageslist.txt | sed 's/<[^>]*>//g;s/10digitphonenumber//g;s/^[\t ]*//;/^$/d;' | sed -n 1~2p > Output1.txt ; sed = Output1.txt | sed 'N;s/\n/\t/' > Output11.txt

egrep -i "ul>|h3>|li>" emailtextmessageslist.txt | sed 's/<[^>]*>//g;s/10digitphonenumber//g;s/^[\t ]*//;/^$/d;s/^.*@/@/;' | sed -n 2~2p > Output2.txt ; sed = Output2.txt | sed 'N;s/\n/\t/' > Output22.txt

#place the output in two separate files.
#number each line
#join the files based on line #
#remove line #s

#join Output11.txt Output22.txt > CombinedOutput.txt
join Output22.txt Output11.txt > CombinedOutput.txt

sed 's/^[0-9]*//;s/^[ ]*//;s/@/\:@/' CombinedOutput.txt | recode html > CleanOutput.txt
#cut -f2 CleanOutput.txt
cut -d":" -f1 CleanOutput.txt
rm Output*.txt CombinedOutput.txt
sed 's/^/<option value=\"/;s/ :/\">/;s/$/<\/option>/' CleanOutput.txt > PHPFormPulldown2.txt