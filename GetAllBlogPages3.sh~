#!/bin/bash
Number_Of_Expected_Args=1
if [ $# -ne $Number_Of_Expected_Args ]
then 
echo "Usage: GetAllBlogPages.sh index.htmlOfBlog "
else

LongURL=1
Quotes=0
Flag=0

#sed works on files, stop trying or making it work on simple strings!

if [ $LongURL = 1 ]
then
#this is the full address of the file, we'll KISS and add the wget later
if [ $Quotes = 1 ] 
then 
echo "L,Q"
FileWebAddress=$( grep "Older Posts" $1 | sed 's/.*http/\"http/' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*/\"/' )  # this is the full web address of the file 
else
echo "L,NQ"
FileWebAddress=$( grep "Older Posts" $1 | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  )  # this is the full web address of the file 
fi

FileLocally=$( grep "Older Posts" $1 | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed  's/%3A/:/g') #this is just the filename
#for some reason I keep getting a wget "Scheme missing" error.  I can put the url command on to the command line and it works but in the script it doesn't for some reason!!!
#So getting rid of the quoted web address, which I though t I needed bc of teh & in the address was causing the Scheme Missing error in the script.
else #Shortened URL
    if [ $Quotes = 1 ] 
    then 
echo "S, Q"
	FileWebAddress=$( grep "Older Posts" $1 | sed 's/.*http/\"http/' | sed -e $'s/[\\\'\"]//g'| sed 's/ id.*//' | sed 's/&.*/\"/' )  # this is the full web address of the file 
#FileWebAddress=$( grep "Older Posts" $1 | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'| sed 's/http/\"http/' | sed 's/ id.*//' | sed 's/ /\"/' | sed 's/%3A/:/g' )  # this is the full web address of the file 
else
echo "Short, NQ"
FileWebAddress=$( grep "Older Posts" $1 | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'| sed 's/http/http/' | sed 's/ id.*//' | sed 's/&.*//' )  # this is the full web address of the file 
#FileWebAddress=$( grep "Older Posts" $1 | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//' | sed 's/%3A/:/g' )  # this is the full web address of the file 
fi

FileLocally=$( grep "Older Posts" $1 | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed 's/&.*/\"/' | sed  's/%3A/:/g') #this is just the filename
fi #end LongURL switch

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

if [ $LongURL = 1 ]
then
#this is the full address of the file, we'll KISS and add the wget later
if [ $Quotes = 1 ] 
then 
echo "L,Q"
FileWebAddress=$( grep "Older Posts" $FileLocally | sed 's/.*http/\"http/' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*/\"/' )  # this is the full web address of the file 
else
echo "L,NQ"
FileWebAddress=$( grep "Older Posts" $FileLocally )
echo "-${FileWebAddress}-"
if [ -z "$FileWebAddress" ]
then
Flag=1 #for just grep will return something diff than grepping then performing some sed commands.
fi
FileWebAddress=$( grep "Older Posts" $FileLocally | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//'  )  # this is the full web address of the file 
fi

FileLocally=$( grep "Older Posts" $FileLocally | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed  's/%3A/:/g') #this is just the filename
#for some reason I keep getting a wget "Scheme missing" error.  I can put the url command on to the command line and it works but in the script it doesn't for some reason!!!
else #Shortened URL
    if [ $Quotes = 1 ] 
    then 
echo "S, Q"
	FileWebAddress=$( grep "Older Posts" $FileLocally | sed 's/.*http/\"http/' | sed -e $'s/[\\\'\"]//g'| sed 's/ id.*//' | sed 's/&.*/\"/' )  # this is the full web address of the file 
#FileWebAddress=$( grep "Older Posts" $FileLocally | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'| sed 's/http/\"http/' | sed 's/ id.*//' | sed 's/ /\"/' | sed 's/%3A/:/g' )  # this is the full web address of the file 
else
echo "Short, NQ"
FileWebAddress=$( grep "Older Posts" $FileLocally | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'| sed 's/http/http/' | sed 's/ id.*//' | sed 's/&.*//' )  # this is the full web address of the file 
#FileWebAddress=$( grep "Older Posts" $FileLocally | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g'|  sed 's/ id.*//' | sed 's/%3A/:/g' )  # this is the full web address of the file 
fi

FileLocally=$( grep "Older Posts" $FileLocally | sed 's/.*href=/wget -nv -nc /' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//'  | sed 's/.*\///' | sed 's/&.*/\"/' | sed  's/%3A/:/g') #this is just the filename
fi #end LongURL switch


echo "Created new FileWebAddress: $FileWebAddress"

#ahh but here I want sed to run on the contents of $FileWebAddress but sed needs a file!
#FileLocally=$( sed 's/.*\///' $FileWebAddress | sed  's/%3A/:/g') #this is just the filename
#FileLocally=$( grep "Older Posts" $FileLocally | sed 's/.*http/http/' | sed -e $'s/[\\\'\"]//g' | sed 's/ id.*//' | sed 's/.*\///' | sed  's/%3A/:/g') #this is just the filename

echo "Created new FileLocally: $FileLocally"
done

fi #end catching of num expected args