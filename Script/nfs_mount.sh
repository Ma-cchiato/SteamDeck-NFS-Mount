#!/bin/bash
# Variables
COLOR_1="\033[1;34m"
COLOR_2="\033[1;31m"
COLOR_END="\033[0m"

directory=/home/deck/NFS
NFS_log="$directory/NFS_log.log"
NFS_settings="$directory/NFS_settings.sh"
Sus_service="$directory/suspend_nfs.service"
Res_service="$directory/resume_nfs.service"
Stu_service="$directory/startup_nfs.service"
Sus_script="$directory/suspend_nfs.sh"
Res_script="$directory/resume_nfs.sh"
Stu_script="$directory/startup_nfs.sh"
systemd="/etc/systemd/system"

req_files=("$NFS_settings" "$Sus_service" "$Res_service" "$Stu_service" "$Sus_script" "$Res_script" "$Stu_script" "$NFS_log" )

Link=("https://raw.githubusercontent.com/Ma-cchiato/SteamDeck-NFS-Mount/main/Script/resume_nfs.sh"
"https://raw.githubusercontent.com/Ma-cchiato/SteamDeck-NFS-Mount/main/Script/startup_nfs.sh")


# Initialize directories and files
if [ ! -d "$directory" ]; then
    echo "Directory does not exist: $directory"        
    mkdir $directory
else
    all_exist=true
    for req_file in "${req_files[@]}"; do
        if [ ! -f "$req_file" ]; then
            all_exist=false
            echo "File does not exist: $req_file"
        fi
    done

    if [ "$all_exist" = true ]; then
        echo "All directories already exist."
    else
        for req_file in "${req_files[@]}"; do
            if [ ! -f "$req_file" ]; then
                touch "$req_file"
                echo "File created: $req_file"
                if [ "$req_file" == "$Res_script" ] || [ "$req_file" == "$Stu_script" ]; then
                    wget "${Link[0]}" -O "$Res_script"
                    wget "${Link[1]}" -O "$Stu_script"
                fi
            fi
        done
    fi
    chmod +x $Sus_script $Res_script $Stu_script
fi

# Service Functions

#suspend_service() {
    
#    cat /dev/null > $Sus_service

#    echo "[Unit]" >> $Sus_script
#    echo "Description=Your Script on Suspend" >> $Sus_service
#    echo -e "\n[Service]" >> $Sus_service
#    echo "Type=oneshot" >> $Sus_service
#    echo "ExecStart=$Sus_script" >> $Sus_service
#    echo -e "\n[Install]" >> $Sus_service
#    echo "WantedBy=sleep.target" >> $Sus_service

#    sudo cp $Sus_service $systemd/suspend_nfs.service
#    sudo systemctl enable suspend_nfs.service
#    sudo systemctl start suspend_nfs.service
    
#}

resume_service() {
    # 서비스 상태 확인

    if systemctl is-enabled --quiet resume_nfs.service; then
        echo "Resume service is already registered."
    else
        echo "Registering Resume service..."
    
        cat /dev/null > $Res_service

        echo "[Unit]" >> $Res_service
        echo "Description=Your Script on Resume" >> $Res_service
        echo -e "\n[Service]" >> $Res_service
        echo "Type=oneshot" >> $Res_service
        echo "ExecStartPre=/bin/sleep 5" >> $Res_service
        echo "ExecStart=$Res_script" >> $Res_service
        echo -e "\n[Install]" >> $Res_service
        echo "WantedBy=suspend.target" >> $Res_service

        sudo cp $Res_service $systemd/resume_nfs.service
        
        # 서비스 등록 및 시작
        
        if sudo systemctl enable resume_nfs.service && sudo systemctl start resume_nfs.service; then
            echo "Resume service has been successfully registered and started."
        else
            echo "Failed to register and start the resume service."
        fi
    fi
}

startup_service() {
    # 서비스 상태 확인

    if systemctl is-enabled --quiet startup_nfs.service; then
        echo "Startup service is already registered."
    else
        echo "Registering Startup service..."
    
        cat /dev/null > $Stu_service

        echo "[Unit]" >> $Stu_service
        echo "Description=My Startup Script" >> $Stu_service
        echo -e "\n[Service]" >> $Stu_service
        echo "Type=oneshot" >> $Stu_service
        echo "ExecStartPre=/bin/sleep 10" >> $Stu_service
        echo "ExecStart=$Stu_script" >> $Stu_service
        echo -e "\n[Install]" >> $Stu_service
        echo "WantedBy=multi-user.target" >> $Stu_service

        sudo cp $Stu_service $systemd/startup_nfs.service
        
        # 서비스 등록 및 시작

        if sudo systemctl enable startup_nfs.service && sudo systemctl start startup_nfs.service; then
            echo "Startup service has been successfully registered and started."
        else
            echo "Failed to register and start the startup service."
        fi
    fi
}

# Package Check and Install Functions
package_check() {

    nfs_module=$(ls -l /lib/modules/$(uname -r)/kernel/fs | grep -E "nfs|nfs_common")

    if [ -n "$nfs_module" ]; then
        pkg_status=1
        pkg_msg=`echo -e "NFS kernel modules are present.\n"`
    else
        pkg_status=2
        pkg_msg=`echo -e "NFS kernel modules are not found.\n"`
    fi
}

package_install() {
    
    sudo steamos-readonly disable
    sudo pacman-key --init
    sudo pacman-key --populate
    sudo pacman -Syy nfs-utils --noconfirm
    sudo steamos-readonly enable
}

# NFS Settings and Mount Functions
set_nfs() {
    
    Set_SSID=""
    NFS_server_IP=""
    NFS_share_path=""
    Mount_path=""

    echo -e "Enter Your NFS Server/Wifi SSID Information \n" 

    touch $NFS_settings
    cat /dev/null > $NFS_settings
    echo "#!/bin/bash" >> $NFS_settings

    read -p "Enter Your WIFI Router-SSID Name : " Set_SSID
    echo "Set_SSID=$Set_SSID" >> $NFS_settings

    read -p "Enter Your NFS Server(NAS) IP Address. ex) 192.168.0.5 : " NFS_server_IP
    echo "NFS_server_IP=$NFS_server_IP" >> $NFS_settings

    read -p "Enter Your NFS Share Path. ex) /volume1/SteamDeck : " NFS_share_path
    echo "NFS_share_path=$NFS_share_path" >> $NFS_settings

    read -p "Enter Your Mount Path. ex) /run/media/DeckNas : " Mount_path
    echo "Mount_path=$Mount_path" >> $NFS_settings

    sudo chmod 755 $NFS_settings

    current_set

    echo "Are you Sure?"
    echo "Enter 'Y' to continue / 'R' to Reconfigure Setting File"
    read reply
    if [ "$reply" == "y" ] || [ "$reply" == "Y" ]; then
        chk_dir
        mount_nfs
    elif [ "$reply" == "r" ] || [ "$reply" == "R" ]; then
	    set_nfs
    else
	    echo "Process terminated"
	    exit
    fi
}

current_set() {

    echo -e "\n"
    echo -e $pkg_msg
    echo -e "\nYour Current Settings"
    echo -e "WIFI Router-SSID Name:      "$COLOR_1 $Set_SSID $COLOR_END
    echo -e "NFS Server(NAS) IP Address: "$COLOR_1 $NFS_server_IP $COLOR_END
    echo -e "NFS Share Path:             "$COLOR_1 $NFS_share_path $COLOR_END
    echo -e "Mount Path:                 "$COLOR_1 $Mount_path $COLOR_END
    echo -e "\n"
}

chk_dir() {

    if [ -d "$Mount_path" ]; then
        echo -e "\n"
        echo -e "Verify directory $Mount_path exists.\n"
    else 
        echo -e "\n"
        echo -e "Directory $Mount_path could not be found. Create a new directory.\n"
        sudo mkdir -p $Mount_path
    fi
}

umount_nfs() {

    if mount | grep -q "$Mount_path"; then
        sudo umount $Mount_path
        echo -e "\nDirectory $Mount_path is unmounted."
        echo "$(date "+%y-%m-%d %H:%M:%S") [Mount Script] NFS Unmounted. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
    else
        echo -e "\n"
        echo -e $COLOR_2"Unmount Failed!!"$COLOR_END
        echo "$(date "+%y-%m-%d %H:%M:%S") [Mount Script] NFS Unount Failed. (Wrong NFS Settings) ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log

    fi
}

mount_nfs() {
    Current_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    #echo $Current_SSID
    #echo $Set_SSID
    current_set
    chk_dir

    if [ "$Current_SSID" == "$Set_SSID" ]; then
        sudo mount -t nfs $NFS_server_IP:$NFS_share_path $Mount_path
        
        if mount | grep -q "$Mount_path"; then
                echo -e "\n"
                echo "Directory $Mount_path is mounted."
                echo "NFS Mount Success!!"
                echo -e "$(date "+%y-%m-%d %H:%M:%S") [Mount Script] NFS Mount Success. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
                #suspend_service
                
                resume_service
                startup_service
        else
                echo -e "\n"
                echo -e $COLOR_2"NFS Mount Failed!!"$COLOR_END
                echo -e $COLOR_2"Check your NFS Server Information\nor Reconfigure your settings.\n"$COLOR_END
                echo "$(date "+%y-%m-%d %H:%M:%S") [Mount Script] NFS Mount Failed. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
                set_nfs
        fi
    else
        umount_nfs
        echo -e "\n"$COLOR_2"NFS Mount Failed!!"$COLOR_END
        echo -e $COLOR_2"Failed to connect "$COLOR_END $COLOR_1$Set_SSID$COLOR_END
        echo -e $COLOR_2"Current SSID is   "$COLOR_END $COLOR_1$Current_SSID$COLOR_END
        echo "$(date "+%y-%m-%d %H:%M:%S") [Mount Script] NFS Mount Failed. ($NFS_server_IP) Current SSID: $Current_SSID" >> $NFS_log
        echo -e "\n"
        set_nfs
    fi
}

missing_alert() {
    echo -e "\nNFS settings don't exist..\n"
    set_nfs
}

# Main Logic

if [ -f $NFS_settings ]; then
    source $NFS_settings
fi

package_check

if [ "$pkg_status" == "2" ]; then
    package_install
fi

if [ -z "$Set_SSID" ] || [ -z "$NFS_server_IP" ] || [ -z "$NFS_share_path" ] || [ -z "$Mount_path" ]; then
    missing_alert
else
    chk_dir
    mount_nfs
fi
