#!/bin/bash
Mens="Men's Clothing"
#echo "${Mens}"
#echo "${Mens/s/99}"
#echo "${Mens/\0047/99}"
echo ${Mens/\'/99}
echo -e "${Mens/\x04D/99}" # x4D is M
echo -e "${Mens/\0047/99}"
echo -e "\0047"
echo "\0047"
#the apostrophe is hex:27 oct:47
echo -e "${Mens/\0047/99}"