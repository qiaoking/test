#!/bin/bash
df -h |grep / | awk '{ print $NF " " $(NF-1)}'|while read output;
do
        echo $output
        echo "===="
        percentage=$(echo $output|awk '{ print $2}' | cut -d'%' -f1 )
        partition=$(echo $output | awk '{ print $1 }' )
        if [ $percentage -ge 80 ]; then
           	echo -e "subject:Disk Alert from Production GitHub server\nfrom:Administrator\nto:Mohan\ Venkatesh Qiao\ King\nRunning out of space \"$partition ($percentage%)\"" | /usr/sbin/sendmail "mohan.venkatesh@emc.com,qiao.king@emc.com,hanumesh.jojode@emc.com,shreyance.shaw@emc.com"
        fi
done

