#/bin/bash
counter=1
ls /boot/ | grep vmlinuz | sed 's@vmlinuz-@linux-image-@g' | grep -v `uname -r ` > /tmp/kernelList
numberOfExtraKernels=`wc -l /tmp/kernelList | awk '{print $1}'`
echo ${numberOfExtraKernels}
for l in `cat /tmp/kernelList`
do
    if [ $counter -lt $numberOfExtraKernels ]
    then 
	aptitude remove $l
	let "counter +=1"
    fi
done
rm -f /tmp/kernelList
update-grub #not sure if it is necessary but taking it as a precautionary step.