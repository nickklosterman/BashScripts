#!/bin/bash
NumberOfExpectedArguments=1

echo "This script will output a list of the newest X files."
if [ $# -ne ${NumberOfExpectedArguments} ]
then 
    echo "Please specify the directory where the sd card resides."
    echo "e.g. $0 /dev/sdb"
    exit
else
    destination=$1
    echo "   Zero the beginning of the SD card or eMMC module:"
    dd if=/dev/zero of="$destination" bs=1M count=8
    echo "   Start fdisk to partition the SD card:"
    echo "   At the fdisk prompt, create the new partitions:"
    echo "     a)  Type o. This will clear out any partitions on the drive."
    echo "     b)  Type p to list partitions. There should be no partitions left."
    echo "     c)  Type n, then p for primary, 1 for the first partition on the drive, and enter twice to accept the default starting and ending sectors."
    echo "     d)  Write the partition table and exit by typing w."
    echo "   Create and mount the ext4 filesystem:"
    fdisk "$destination"
    mkfs.ext4 "$destination"1
    if [ ! -e  root ]
    then 
	mkdir root
    fi
    mount "$destination"1 root
    echo "   Download and extract the root filesystem (as root, not via sudo):"
    if [ ! -e ArchLinuxARM-odroid-c1-latest.tar.gz ]
    then
	wget http://archlinuxarm.org/os/ArchLinuxARM-odroid-c1-latest.tar.gz
    fi

    bsdtar -xpf ArchLinuxARM-odroid-c1-latest.tar.gz -C root
    echo "   Flash the bootloader files:"
    cd root/boot
    ./sd_fusing.sh "$destination"
    cd ../..
    echo "   (Optional) Set the screen resolution for your monitor:"
    echo "     a)  Open the file root/boot/boot.ini with a text editor."
    echo "     b)  Uncomment the line with the desired resolution, and ensure all others are commented."
    echo "     c)  Save and close the file."
    echo "    Unmount the partition:"
    umount root
    echo "    Insert the micro SD card or eMMC module into the C1, connect ethernet, and apply 5V power."
    echo "    Use the serial console (with a null-modem adapter if needed) or SSH to the IP address given to the board by your router."
    echo "        Login as the default user alarm with the password alarm."
    echo "        The default root password is root."
fi

echo "Directions taken from:  http://archlinuxarm.org/platforms/armv7/amlogic/odroid-c1"