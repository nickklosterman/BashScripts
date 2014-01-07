#!/bin/bash
Number_Of_Expected_Args=1
if [ $# -ne $Number_Of_Expected_Args ]
then 
    echo "Usage: GetAllBlogPages.sh www.blogurl.com "
else

    #obtain the initial webpage 
    wget "$1" -O index.html
    LongURL=1
    Quotes=0
    Flag=0

    #sed works on files, stop trying or making it work on simple strings!


    echo "L,NQ"
    FileWebAddress=$( grep "Older Posts" index.html | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  )  # this is the full web address of the file '

    if [ "$FileWebAddress" == "" ]
    then
	FileWebAddress=$( grep "Post più vecchi" index.html | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  ) #'
    fi #this is for Sara Pichelli's comics webpage to catch the "older pages" in Italian

    FileLocally=$( grep "Older Posts" index.html | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed  's/%3A/:/g') #this is just the filename'
    #for some reason I keep getting a wget "Scheme missing" error.  I can put the url command on to the command line and it works but in the script it doesn't for some reason!!!
    #So getting rid of the quoted web address, which I though t I needed bc of teh & in the address was causing the Scheme Missing error in the script.

    FileLocally=$( grep "Older Posts" index.html | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed 's/&.*/\"/' | sed  's/%3A/:/g') #this is just the filename'

    if [ "$FileLocally" == "" ]
    then
	FileLocally=$( grep "Post più vecchi" index.html | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  ) #'
    fi #this is for Sara Pichelli's comics webpage to catch the "older pages" in Italian                                                    
    echo "End Initial Grab"
    echo $FileWebAddress
    echo $FileLocally  
    #you may need to remove the &max-results... with  sed 's/&.*//' 
    #append to end of line sed 's/$/someshit/'

    #continue to crawl the subsequent files getting the next page of the blog i.e. the ""Older Posts" Posts" link
    while [ "$FileWebAddress" != " " ] && [ $Flag  = 0 ] # from http://linuxcommand.org/wss0100.php for why complaining about unary operator and "$var" is diff than $var
    do 
	echo "While loop"
	echo "Getting Online File"
	echo "-${FileWebAddress}-"

	wget  -nc -nv $FileWebAddress 
	#-o wgetlog.txt
	#-nc -nv = no clobber, non verbose

	#curl  $FileWebAddress

	echo "L,NQ"
	FileWebAddress=$( grep "Older Posts" "$FileLocally" )
	if [ "$FileWebAddress" == "" ]
	then
	    FileWebAddress=$( grep "Post più vecchi" "$FileLocally" )
	fi #this is for Sara Pichelli's comics webpage to catch the "older pages" in Italian                  

	echo "-${FileWebAddress}-"
	if [ -z "$FileWebAddress" ]
	then
	    Flag=1 #for just grep will return something diff than grepping then performing some sed commands.
	fi

	FileWebAddress=$( grep "Older Posts" "$FileLocally" | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  )  # this is the full web address of the file '

	if [ "$FileWebAddress" == "" ]
	then
	    FileWebAddress=$( grep "Post più vecchi" "$FileLocally" | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  ) #'
	fi #this is for Sara Pichelli's comics webpage to catch the "older pages" in Italian                 


	FileLocally=$( grep "Older Posts" "$FileLocally" | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed  's/%3A/:/g') #this is just the filename'
	#for some reason I keep getting a wget "Scheme missing" error.  I can put the url command on to the command line and it works but in the script it doesn't for some reason!!!

	if [ "$FileLocally" == "" ]
	then
	    FileLocally=$( grep "Post più vecchi" "$FileLocally" | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  ) #'
	fi #this is for Sara Pichelli's comics webpage to catch the "older pages" in Italian

	echo "Created new FileWebAddress: $FileWebAddress"

	#ahh but here I want sed to run on the contents of $FileWebAddress but sed needs a file!
	#FileLocally=$( sed 's/.*\///' $FileWebAddress | sed  's/%3A/:/g') #this is just the filename
	#FileLocally=$( grep "Older Posts" $FileLocally | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//' | sed 's/.*\///' | sed  's/%3A/:/g') #this is just the filename

	echo "Created new FileLocally: $FileLocally"
    done

fi #end catching of num expected args

cat index.html search* > BLOG.html
