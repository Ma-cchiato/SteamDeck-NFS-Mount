#!/bin/bash

directory=/home/deck/NFS
source "$directory/NFS_settings.sh"
NFS_log="$directory/NFS_log.log"

umount_nfs () {

sudo umount $Mount_path
echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] Directory $Mount_path is unmounted. ($NFS_server_IP) Current SSID: $Current_SSID" >>  $NFS_log

}

Current_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ "$Current_SSID" != "$Set_SSID" ]; then
    echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] NFS Mount Failed!! ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
    umount_nfs
else
    echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] NFS Mount Success!! ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
fi
