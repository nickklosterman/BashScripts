#!/bin/bash

function GetWebpageBeginTag ()
{
case ${1} in 
"http://www.steepandcheap.com") 
echo "<SaC>";;
"http://www.whiskeymilitia.com")
echo "<WM>";;
"http://www.bonktown.com")
echo "<BT>";;
"http://www.chainlove.com")
echo "<CL>";;
*)
echo "GetWebpageBeginTag Error"
esac
}

function GetWebpageEndTag ()
{
case ${1} in 
"http://www.steepandcheap.com") 
echo "<\/SaC>";; #need the extra \ to escape since we are using it in a sed command 
"http://www.whiskeymilitia.com")
echo "<\/WM>";;
"http://www.bonktown.com")
echo "<\/BT>";;
"http://www.chainlove.com")
echo "<\/CL>";;
*)
echo "GetWebpageEndTag Error"
esac
}

function GetPageReturnText()
{
#this function gets a webpage and returns the desired text 
Webpage=`mktemp`
wget ${1} -O ${Webpage} -q
#WebsiteBeginTag=$(GetWebpageBeginTag ${1} )
#WebsiteEndTag=$(GetWebpageEndTag ${1} )
#OutputText=`grep "<title>" ${Webpage} | sed 's/<title>/'${WebsiteBeginTag}'/' | sed 's/<\/title>/'${WebsiteEndTag}'/' `
OutputText=`grep "<title>" ${Webpage} | sed 's/<title>//' | sed 's/<\/title>//' `
echo ${OutputText}
}

function GetPageReturnImage()
{
#this function gets a webpage and returns the desired text 
Webpage=`mktemp`
wget ${1} -O ${Webpage} -q
case ${1} in 
"http://www.steepandcheap.com") 
OutputText=`grep "item_image" ${Webpage} | sed 's/<div id=\"item_image\"><img src=\"//' | sed 's/".*//' `;;
"http://www.whiskeymilitia.com"|"http://www.chainlove.com"|"http://www.bonktown.com")
OutputText=`grep "mainimage" ${Webpage} | sed 's/<img name=\"mainimage\" src=\"//' | sed 's/".*//' `;;
esac
Image=`mktemp`
wget ${OutputText} -O ${Image} -q
echo ${Image}
}

#SteepAndCheap=\"$(GetPageReturnText http://www.steepandcheap.com )\"
SteepAndCheap=$(GetPageReturnText http://www.steepandcheap.com )
SteepAndCheapImage=$(GetPageReturnImage http://www.steepandcheap.com )
echo ${SteepAndCheap} 
#echo "Image:"${SteepAndCheapImage} 
if [ 1 -lt 2 ]
then
WhiskeyMilitia=$(GetPageReturnText http://www.whiskeymilitia.com )
WhiskeyMilitiaImage=$(GetPageReturnImage http://www.whiskeymilitia.com )
echo ${WhiskeyMilitia}
Bonktown=$(GetPageReturnText http://www.bonktown.com )
BonktownImage=$(GetPageReturnImage http://www.bonktown.com )
echo ${Bonktown}
Chainlove=$(GetPageReturnText http://www.chainlove.com )
ChainloveImage=$(GetPageReturnImage http://www.chainlove.com )
echo ${Chainlove}
fi
#these two websites were killed
#Tramdock=$(GetPageReturnText http://www.tramdock.com )
#Brociety=$(GetPageReturnText http://www.brociety.com )
#Concatenation=${SteepAndCheap}+${WhiskeyMilitia}+${Bonktown}+${Chainlove}
#gxmessage -buttons "OK:1" -default "OK" -center -font "serif 16" -fg "#579" -bg white -wrap -title "Steep and Cheap" ${SteepAndCheap}
#SteepAndCheap="234 24"
#notify-send ${SteepAndCheap} attempting these methods gets us the "Invalid number of options" error
#notify-send \'${SteepAndCheap}\'

notify-send "$SteepAndCheap" -i ${SteepAndCheapImage} -t 3
#notify-send -t 0 "$SteepAndCheap" -i ${SteepAndCheapImage} #the -t 0 automatically overrides the icon giving a red excl point icon instead of the one specified
#feh ${SteepAndCheapImage}
notify-send  "$WhiskeyMilitia" -i ${WhiskeyMilitiaImage} -t 3
notify-send  "$Bonktown" -i ${BonktownImage} -t 3
notify-send  "$Chainlove" -i ${ChainloveImage} -t 3
#notify-send -t 0 -u low -i gtk-dialog-info "$SteepAndCheap"
#grep for <img name="mainimage" src="...... to grab the featured image of the product
#grep for <meta name="description" content=".... to grab a short product description ---ehh not really worth it cuz it is a goody wootish type of description