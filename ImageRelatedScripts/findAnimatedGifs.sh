#!/bin/bash

# for item in *.gif
# 	    do
# 		result=$( identify -format "%n" ${item} )
# 		echo ${result}
# 		if [ "${result}" -gt 0 ]
# 		then
# 		    echo " animated : ${item}"
# 		else
# 		    echo "not animated : ${item}"
# 		fi
# done

echo "I probably want to modify this so it can be piped to eog somehow"
find . -type f -name \*.gif -exec sh -c  'identify -format "%[fx:n>1]\n" "$0" | grep -q 1' {} \; -print  #http://unix.stackexchange.com/a/224645 http://unix.stackexchange.com/questions/224631/find-all-animated-gif-files-in-a-directory-and-its-subdirectories
