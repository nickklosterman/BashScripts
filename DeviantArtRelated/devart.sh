#!/bin/bash

# devart.sh by wlourf 15/02/2011.
# this script retrieves the number of messages on a deviantArt account
# run the script for more information on the parameters
# be careful : the password is NOT ENCRYPTED

#PARAMETERS BEGIN HERE  
username="bithynia"
password="fluorescenthell"
cookie="/tmp/cookie-da.txt"
page="/tmp/da-page.html"
#PARAMETERS ENDS HERE

if [[ $# < 1 ]]; then
    echo "This script needs at least one parameter: "
    echo "  1 : load and read the deviantArt page"
    echo "  0 : read the deviantArt page in memory"
    echo 
    echo "Second parameter is optional :"
    echo "  notices, messages, feedbacks or notes"
    echo "  if no parameter is set, the script will display the 4 values above"
    exit 1
fi
if [[ "$1" == "1" ]]; then
    curl -c "$cookie" -d "username=$username&password=$password" https://www.deviantart.com/users/login
    curl -b "$cookie" -s http://my.deviantart.com/messages/ > "$page"
fi

function get_nb() {
    echo `cat $page | grep "View All Messages" | awk -F'i'$1'"></i>' '{print $2}' | awk -F'<span' '{print $1}'`
}
notices=$(get_nb 3)
messages=$(get_nb 1)
feedbacks=$(get_nb 2)
notes=$(get_nb 9)

if [[ $notices == "" ]]; then notices=0;fi
if [[ $messages == "" ]]; then messages=0;fi
if [[ $feedbacks == "" ]]; then feedbacks=0;fi
if [[ $notes == "" ]]; then notes=0;fi

case $2 in
    "notices")
        echo $notices;;
    "messages")  echo $messages;;
    "feedbacks")
        echo $feedbacks;;
    "notes")
        echo $notes;;
    *)
        echo $notices
        echo $messages
        echo $feedbacks
        echo $notes  
esac          


exit 0