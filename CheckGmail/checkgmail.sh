#! /bin/bash
# checking for new emails @ gmail http://lxer.nl/webdevelopment/gmail/

# created by Lxer 2008
#

# check your modifier keysettings:  xmodmap
# to get scroll lock led working: xmodmap -e 'add mod3 = Scroll_Lock'
#  or add it to modmap: gedit ~/.Xmodmap ,  add mod3 = Scroll_Lock

# to have this script running in the background and checking
# it  repeatedly, use:
#   sudo watch --interval=300 gmail &> /dev/null &
# or set as cronjob
#
#####################
# replace these with your account settings :
username=( username1 username2 username3 )
passwd=( pass1 pass2 pass3 )
tempfile="/tmp/gm/"

#########
a=0
for (( i = 0 ; i < ${#username[@]} ; i++ )) ; do
   wget -q -P $tempfile https://${username[$i]}:${passwd[$i]}@mail.google.com/mail/feed/atom
   if [ -f $tempfile"atom" ]; then
      email=`sed -n -e 's/<\/*fullcount>//pg'  $tempfile"atom"`
   if [ "$email" != "0" ]; then
      echo -e "New emails: \033[1m $email \033[0m  account: \033[1m ${username[$i]}  \033[0m"
      sed -n -e 's/< \/*summary>/\r/pg' $tempfile"atom"
      a=1
   fi
#   rm $tempfile"atom"
else
   echo $name3 : Login failed.
fi
done

# print url for easy access
if [ $a -eq 1 ]; then
   echo "http://www.gmail.com"
fi

#blinkenlight
if [[ $EUID -eq 0 ]]; then # only if root
   if [ $a -eq 1 ]; then
      ledcontrol set s5 on
   else
      ledcontrol set s5 off
   fi
fi