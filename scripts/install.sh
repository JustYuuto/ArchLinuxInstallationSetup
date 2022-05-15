#!/bin/env /usr/bin/bash

# Colors

reset="\033[0m"

blue="\033[0;34m"
red="\033[0;31m"

bold_white="\033[1;37m"
bold_blue="\033[1;34m"
bold_red="\033[1;31m"

# END Colors

# Functions

step () {
    clear

    name=$1
    line=""

    for (( i=0; i<${#name}; i++ )) ; do
        line+="="
    done

    echo -e "${bold_white}${name}${reset}"
    echo $line
}

question () {
    echo -e "${bold_white}> ${reset}$1"
}

# END Functions

# Check if setup is running on Arch Linux
#if [ uname != "Arch Linux" ] ; then
#    echo -e "${bold_red}The setup needs to be on Arch Linux to run.${reset}"
#    exit 0
#fi

#echo -e "Checking for an Internet connection..."
#ping_cmd="ping -c1 archlinux.org"
#if [ $ping_cmd == *"Name or service not known" ] ; then
#    echo -e "${bold_red}An Internet connection is required to install Arch Linux.${reset}"
#    exit 0
#fi

clear

# Header

echo "#######################################################"
echo
echo "             Arch Linux Installation Setup"
echo "       Made by NetherMC (github.com/NetherMCtv)"
echo
echo "#######################################################"
echo ""

# END Header

if [ -d "/sys/firmware/efi/efivars" ] ; then
    echo -e "${bold_blue}INFO:${reset} The Arch ISO is booted in UEFI mode"
else
    echo -e "${bold_blue}INFO:${reset} The Arch ISO is booted in BIOS mode"
fi

timedatectl set-ntp true
echo ""

step "Disk Partitionning"

echo ""

echo -e "${bold_white}Disks list:${reset}"
sudo lsblk

echo ""
question "On which disk do you want to install Arch Linux?"
read disk_to_install
echo ""

if [[ $(grep "$disk_to_install" /etc/mtab) == "" || "$disk_to_install" != "/dev/"* ]] ; then
    echo -e "${bold_red}The selected disk does not exist! ${red}Please choose another disk.${reset}"
else
    echo -e "Partitionning ${bold_white}${disk_to_install}${reset}..."

    echo -e "Formatting partitions..."
    #mkfs.ext4 /dev/root_partition
    #mkswap /dev/swap_partition
    #mkfs.fat -F 32 /dev/efi_system_partition
fi