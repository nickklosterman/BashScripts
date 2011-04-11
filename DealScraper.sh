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
WebsiteBeginTag=$(GetWebpageBeginTag ${1} )
WebsiteEndTag=$(GetWebpageEndTag ${1} )
OutputText=`grep "<title>" ${Webpage} | sed 's/<title>/'${WebsiteBeginTag}'/' | sed 's/<\/title>/'${WebsiteEndTag}'/' `
echo ${OutputText}
}

SteepAndCheap=$(GetPageReturnText http://www.steepandcheap.com )
echo ${SteepAndCheap}
WhiskeyMilitia=$(GetPageReturnText http://www.whiskeymilitia.com )
echo ${WhiskeyMilitia}
Bonktown=$(GetPageReturnText http://www.bonktown.com )
echo ${Bonktown}
Chainlove=$(GetPageReturnText http://www.chainlove.com )
echo ${Chainlove}
Concatenation=${SteepAndCheap}+${WhiskeyMilitia}+${Bonktown}+${Chainlove}
#gxmessage -buttons "OK:1" -default "OK" -center -font "serif 16" -fg "#579" -bg white -wrap -title "Steep and Cheap" ${SteepAndCheap}
notify-send \"${SteepAndCheap}\"
notify-send \"${WhiskeyMilitia}\"
notify-send ${Bonktown}
notify-send ${Chainlove}
#grep for <img name="mainimage" src="...... to grab the featured image of the product
#grep for <meta name="description" content=".... to grab a short product description ---ehh not really worth it cuz it is a goody wootish type of description