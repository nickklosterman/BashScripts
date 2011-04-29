#!/bin/bash
function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage=`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
}
function GivePageReturnDescription()
{
    OutputText=`grep "<h2 class=\"fn\">" ${1} | sed 's/<[^>]*>//g' `
#| sed -e 's/]*>//g' `
#sed -e 's#<[^>]*>##g' `
#sed 's@<\([^<>][^<>]*\)>\([^<>]*\)</\1>@\2@g' `
#'s/<[^>]*>//g' `
    echo "Des" ${OutputText}
}
function GivePageReturnPrice()
{
    OutputText=`grep "<h3 class=\"price\">" ${1} | sed 's/<[^>]*>//g' `
    echo "Price" ${OutputText}
}
function GivePageReturnCondition()
{ #on line 96
    OutputText=`sed -n '96p;s/<[^>]*>//g'< ${1} `

#grep -C 2 "<dt>Condition:" ${1}  `  -A 2
#| tr -d "\n"  `
    echo "Cond+=" ${OutputText}
}
function GivePageReturnTechnicalDescription()
{
    OutputText=`sed -n '100p' < ${1} `
    echo ${OutputText}
}


function GivePageReturnFullImage()
{
    Webpage=${1}
    OutputText=`grep "class=\"photo\""  ${Webpage} | grep "sale.images" | sed 's/.*http:/http:/' | sed 's/".*//'` ;
    echo ${OutputText}
#    Image=`mktemp`
#    wget ${OutputText} -O ${Image} -q
#    echo ${Image}
}

function GivePageReturnDetailImage()
{
    Webpage=${1}
    OutputText=`grep "class=\"lightBox\"" ${Webpage} | sed 's/.*http:\/\/sale.images/http:\/\/sale.images/' | sed 's/".*//' `;
    echo ${OutputText}
 #   Image=`mktemp`
 #   wget ${OutputText} -O ${Image} -q
 #   echo ${Image}
}
function GivePageReturnThumbnailImage()
{
    Webpage=${1}
    OutputText=`grep "<meta property=\"og:image" ${Webpage} | sed 's/.*http/http/' | sed 's/".*//' `;
    echo ${OutputText}
    #Image=`mktemp`
    #wget ${OutputText} -O ${Image} -q
    #echo ${Image}
}

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

Woot=$(GetPageReturnFile http://kids.woot.com )
#Description
GivePageReturnDescription ${Woot}
GivePageReturnPrice ${Woot}
#Price=
#Condition
GivePageReturnCondition ${Woot} 
GivePageReturnTechnicalDescription ${Woot}
Thumbnail=$(GivePageReturnThumbnailImage ${Woot} )
feh ${Thumbnail} & 
Full=$(GivePageReturnFullImage ${Woot} )
Detail=$(GivePageReturnDetailImage ${Woot} )
GivePageReturnDetailImage ${Woot} 
feh ${Full} & 
feh ${Detail} & 
echo "How fucking cool is that. You can feed feh the url of an image (or a list of urls) and it'll display the images!"