#!/bin/bash
ls /boot/ | grep vmlinuz | sed 's@vmlinuz-@linux-image-@g' | grep -v `uname -r` > /tmp/kernelList
for l in `cat /tmp/kernelList`
do
aptitude remove $l
done
rm -f /tmp/kernelList

update-grub