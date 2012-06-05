#!/bin/bash
function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage='/tmp/GenericWoot' 
    wget ${1} -O ${Webpage} -q

    bob=$( grep href=\"/offers/ ${Webpage} -m 1 | sed 's/^.*href="//;s/".*//' )
    wget ${1}${bob} -O ${Webpage} -q
    echo ${Webpage}
}

function GivePageReturnDescription()
{
#old woot    OutputText=`grep "<h2 class=\"fn\">" ${1} | sed 's/<[^>]*>//g' `
    OutputText=`grep "id=\"content" ${1} -A 20 | grep "<h1>" | sed 's/<[^>]*>//g' `
    echo  ${OutputText}
}
function GivePageReturnPrice()
{
#old woot (pre June 2012)    OutputText=`grep "<h3 class=\"price\">" ${1} | sed 's/<[^>]*>//g' `
    OutputText=`grep "id=\"content" ${1} -A 20 | grep "<span class=\"price\">" | sed 's/<[^>]*>//g' `
    echo  ${OutputText}
}
function GivePageReturnCondition()
{ #on line 96
#    OutputText=`sed -n '96p;s/<[^>]*>//g'< ${1} | sed 's/<[^>]*>//g' `
    OutputText=`grep "<span id=\"attr-condition\">"  ${1} | sed 's/<[^>]*>//g' `
    echo "Condition:" ${OutputText}
}
function GivePageReturnTechnicalDescription()
{
#    OutputText=`sed -n '100p' < ${1} `

    OutputText=`grep "<article class=\"primary-content\">" ${1} -A 18 | sed 's/<[^>]*>//g' `
    echo ${OutputText}
}


function GivePageReturnFullImage()
{
    Webpage=${1}
    OutputText=`grep "class=\"photo\""  ${Webpage} | grep "sale.images" | sed 's/.*http:/http:/' | sed 's/".*//'` ;
    echo ${OutputText}
}
function GivePageReturnFullShirtImage()
{
    Webpage=${1}
    OutputText=`grep "class=\"photo\""  ${Webpage} | grep "sale.images" | sed 's/.*href=\"http:/http:/;s/".*//'` ;
    echo ${OutputText}
}

function GivePageReturnDetailImage()
{
    Webpage=${1}

#    OutputText=`grep "class=\"lightBox\"" ${Webpage} | sed 's/.*http:\/\/sale.images/http:\/\/sale.images/g;s/".*//' `;
# or key off of : "<div class=\"photo fullsize"
    OutputText=`grep "<div id=\"gallery\">" ${Webpage} -A 20 | grep http | sed 's/.*img src=\"//g;s/".*//' `;
    echo ${OutputText}
}
function GivePageReturnDetailShirtImage()
{
    Webpage=${1}
    OutputText=`grep "class=\"lightBox\"" ${Webpage} | sed 's/.*href=\"http:\/\/sale.images/http:\/\/sale.images/g;s/".*//' `;

    echo ${OutputText}
}
function GivePageReturnThumbnailImage()
{
    Webpage=${1}
    OutputText=`grep "<meta property=\"og:image" ${Webpage} | sed 's/.*http/http/' | sed 's/".*//' `;
    echo ${OutputText}
}
function cleanup()
{
    if [ -e /tmp/GenericWoot  ]
    then
	rm /tmp/GenericWoot
    fi
    exit 1
}


#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------
trap cleanup SIGINT
if [ $# -lt 1 ]
then 
    echo "You need to supply the name of the Woot website that we'll be scraping.\n http://kids.woot.com http://wine.woot.com http://www.woot.com"
    exit 1
else
    
    Website=${1}
    Woot=$(GetPageReturnFile ${Website} )
    
    GivePageReturnDescription ${Woot}
    GivePageReturnPrice ${Woot}

    if [ "${Website}" != "shirt.woot.com" ] && [ "${Website}" != "wine.woot.com" ]
    then
	GivePageReturnCondition ${Woot} 
    fi
    GivePageReturnTechnicalDescription ${Woot}

#only show the FULL image for the shirt, for all other products the full image is repeated in the DETAIL images anyway
    if [ "${Website}" == "shirt.woot.com" ]
    then
	Full=$(GivePageReturnFullShirtImage ${Woot} )
	feh ${Full} & 
    fi
    Detail=$(GivePageReturnDetailImage ${Woot} )
    feh ${Detail} & 
fi
#cleanup