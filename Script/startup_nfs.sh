#!/bin/bash

directory=/home/deck/NFS
source "$directory/NFS_settings.sh"
NFS_log="$directory/NFS_log.log"

chk_dir() {

    if [ -d "$Mount_path" ]; then
        echo -e "\n"
        echo -e "Verify directory $Mount_path exists.\n" >> $NFS_log
    else 
        echo -e "\n"
        echo -e "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] Directory $Mount_path could not be found. Create a new directory.\n" >> $NFS_log
        sudo mkdir -p $Mount_path
    fi
}

umount_nfs () {

sudo umount $Mount_path
echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] Directory $Mount_path is unmounted. ($NFS_server_IP) Current SSID: $Current_SSID" >>  $NFS_log

}

mount_nfs() {
    Current_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    chk_dir
    if [ "$Current_SSID" == "$Set_SSID" ]; then
        sudo mount -t nfs $NFS_server_IP:$NFS_share_path $Mount_path
        
        if mount | grep -q "$Mount_path"; then
            echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] NFS Mount Success. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
        else
            umount_nfs
            echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] NFS Mount Failed. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
        fi
    else
        umount_nfs
        echo "$(date "+%y-%m-%d %H:%M:%S") [Startup Script] NFS Mount Failed. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
    fi
}

mount_nfs
