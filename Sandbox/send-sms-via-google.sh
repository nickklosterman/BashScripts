#!/bin/bash
# args: carrier, 10-digit-phone, "message"

msg="$(echo "$3" | sed 's| |+|g;s|\\n|%0D%0A|g')"
carrier="$(echo "$1" | tr 'a-z' 'A-Z')"
post="gl=US&hl=en&client=navclient-ffsms&text=h4ck3d&from=&c=1&mobile_user_id=$2&carrier=$carrier&ec=on&subject=&text=$msg&send_button=Send"
addr='http://www.google.com/sendtophone'
echo -n 'Sending message...     '
ret="$(wget -qO- --post-data "$post" "$addr")"
echo "$ret"
echo "a null return message doesn't necessarily mean it wasn't sent. It doesn't appear to be an actively supported product anymore and several ppl think it is  dead"
if echo "$ret" | grep -q 'Message sent!' ; then
  echo 'OK'
else
  if echo "$ret" | grep -qi 'captcha' ; then
    echo 'FAIL: CAPTCHA AUTH REQUIRED'
  else
    echo 'FAIL: UNKNOWN ERROR'
  fi
fi

exit 0