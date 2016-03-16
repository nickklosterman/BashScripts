#!/bin/bash
destination="/dev/sdb"

dd if=/dev/zero of="$destination" bs=1M count=8
#Start fdisk to partition the SD card:
fdisk "$destination"
#At the fdisk prompt, delete old partitions and create a new one:

#    Type o. This will clear out any partitions on the drive.
#    Type p to list partitions. There should be no partitions left.
#    Now type n, then p for primary, 1 for the first partition on the drive, 2048 for the first sector, and then press ENTER to accept the default last sector.
#    Write the partition table and exit by typing w.

#Create and mount the ext4 filesystem:
mkfs.ext4 "$destination"1
if [ ! -e mnt ]
then 
mkdir mnt
fi 
mount "$destination"1 mnt
#Download and extract the root filesystem:
if [ ! -e ArchLinuxARM-am33x-latest.tar.gz ]
then
    wget http://archlinuxarm.org/os/ArchLinuxARM-am33x-latest.tar.gz
fi

bsdtar -xpf ArchLinuxARM-am33x-latest.tar.gz -C mnt
sync
#Install the U-Boot bootloader:
dd if=mnt/boot/MLO of="$destination" count=1 seek=1 conv=notrunc bs=128k
dd if=mnt/boot/u-boot.img of="$destination" count=2 seek=1 conv=notrunc bs=384k
umount mnt
sync 

#pacman -Syu wget dosfstools
#scp -P 510 nicky@192.168.1.111:/home/nicky/ArchLinux*.gz /home/alarm/
