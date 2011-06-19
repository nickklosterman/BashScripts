#!/bin/bash
foo="What in the Devil is going on here!"
bar="What*Dev" #I fail!
bar="What.*Dev"
if grep  -q $bar <<<"$foo "
then 
echo "woohoo"
else
echo "poopoo"
fi