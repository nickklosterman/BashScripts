#!/bin/bash
info=$(eval "$*" 2>/dev/null)
notify-send -t $((1000+300*`echo -n $info | wc -w`)) -u low -i gtk-dialog-info "$*" "$info" || exit 2
#taken from http://crunchbanglinux.org/forums/topic/2848/bash-at-your-fingertips-nifty-notifysend/