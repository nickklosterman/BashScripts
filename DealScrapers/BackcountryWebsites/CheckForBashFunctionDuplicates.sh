#!/bin/bash
filename=${1}
grep function "${filename}" | sort | uniq -c
#uniq -d --> only show duplicates...but don't use because then we might have forgotten the () at the end of the function and this would give a fals negative
#uniq -c --> counts occurrences but not very useful
