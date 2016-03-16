#!/bin/bash
target=$1
cp ArchLinuxARM-am33x-latest.tar.gz /media/"$target"/home/alarm
# from https://eewiki.net/display/linuxonarm/BeagleBone+Black there is a link to copy to the emmc 
cp bbb-eMMC-flasher-eewiki-ext4.sh /media/"$target"/home/alarm
cp installToMMC.sh /media/"$target"/home/alarm
emacs ~/.ssh/known_hosts

