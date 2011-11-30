#!/bin/bash
for image in *.[jgpJPG][ipnIPN][fgFG] #this should match all upper and lower case png gif jpg 
do
mogrify "$image" -geometry 800x600
done

