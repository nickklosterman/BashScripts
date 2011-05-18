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
    echo ${OutputText}
}
function GivePageReturnPrice()
{
    OutputText=`grep "<h3 class=\"price\">" ${1} | sed 's/<[^>]*>//g' `
    echo "Price" ${OutputText}
}

function GivePageReturnCondition()
{ #on line 96
    OutputText=`sed -n '97,99p'< ${1} `
#| sed 's/<[^>]*>//g' `
#grep -C 2 "<dt>Condition:" ${1}  ` 
#| tr -d "\n"  `
    echo "Cond+=" ${OutputText}
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
#    OutputText=`grep "class=\"lightBox\"" ${Webpage} | sed 's/.*http:\/\/sale.images/http:\/\/sale.images/' | sed 's/".*//' `;

#The file has two images on one line and I want to capture both.
#I don't know how to get both with sed so I reused a trick
#where I split all http refs onto different lines and work 
#on each separately
    #OutputText=`grep "class=\"lightBox\"" ${Webpage}  | sed -e 's/\"http/\n\"http/g' | sed 's/.*http:\/\/sale.images/http:\/\/sale.images/' | sed 's/".*//' | grep woot`;

    OutputText=`grep "class=\"lightBox\"" ${Webpage}  | sed 's/<[^>]*\"http/\nhttp/g' | sed 's/".*//'` #| sed 's/"[^(http)]*>//g' ` ;
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

Woot=$(GetPageReturnFile http://shirt.woot.com )
#Description

GivePageReturnPrice ${Woot}
GivePageReturnDescription ${Woot}
#Thumbnail=$(GivePageReturnThumbnailImage ${Woot} )
#feh ${Thumbnail} & 
#Full=$(GivePageReturnFullImage ${Woot} )
Detail=$(GivePageReturnDetailImage ${Woot} )
#GivePageReturnDetailImage ${Woot} 
#feh ${Full} & 
feh ${Detail} & 
#echo "How fucking cool is that. You can feed feh the url of an image (or a list of urls) and it'll display the images!"
echo "wget ${Detail}"