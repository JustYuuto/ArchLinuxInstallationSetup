#!/bin/env /usr/bin/bash

reset="\033[0m"

blue="\033[0;34m"
red="\033[0;31m"

bold_white="\033[1;37m"
bold_blue="\033[1;34m"
bold_red="\033[1;31m"
bold_green="\033[1;32m"

######################################################################################

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
    sleep 5
    echo -e "${bold_white}> ${reset}$1"
    echo ""
}

######################################################################################

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

######################################################################################

echo "#######################################################"
echo
echo "             Arch Linux Installation Setup"
echo "       Made by NetherMC (github.com/NetherMCtv)"
echo
echo "#######################################################"
echo ""

######################################################################################

if [ -d "/sys/firmware/efi/efivars" ] ; then
    echo -e "${bold_white}[${bold_blue}INFO${bold_white}]${reset} Arch ISO booted in UEFI mode"
    is_uefi=1
else
    echo -e "${bold_white}[${bold_blue}INFO${bold_white}]${reset} Arch ISO booted in BIOS mode"
    is_uefi=0
fi

timedatectl set-ntp true

######################################################################################

step "Disk Partitionning"

# NOTES:
# {DISK}1 is the ESP
# {DISK}2 is the Swap Partition
# {DISK}3 is the Linux FS Partition

echo ""
echo -e "${bold_white}Disks list:${reset}"
lsblk

echo ""
echo -e "${bold_red}WARNING: THE DISK WILL BE FORMATED! ALL DATA ON IT WILL BE LOST!${reset}"
question "On which disk do you want to install Arch Linux?"
read disk_to_install
echo ""

if [[ "$disk_to_install" != "/dev/"* ]] ; then
    echo -e "${bold_red}The selected disk does not exist! ${red}Please choose another disk.${reset}"
else
    echo -e "Partitionning ${bold_white}${disk_to_install}${reset}..."

    if [ $is_uefi == 1 ] ; then
        parted $disk_to_install mklabel gpt
    else
        parted $disk_to_install mklabel mbr
    fi
    parted $disk_to_install version

    echo -e "Disk successfully partitionned without errors."

    echo -e "Formatting partitions..."
    mkfs.ext4 "${disk_to_install}3"
    mkswap "${disk_to_install}2"
    mkfs.fat -F 32 "${disk_to_install}1"
fi

echo -e "Mounting ${bold_white}${disk_to_install}3${reset} (FS) to ${bold_white}/mnt${reset}..."
mount "${disk_to_install}3" /mnt

echo -e "Mounting ${bold_white}${disk_to_install}1${reset} (ESP) to ${bold_white}/mnt/boot${reset}..."
mount "${disk_to_install}1" /mnt/boot

swapon /dev/sda2

######################################################################################

step "Packages installation"

echo ""
echo -e "${bold_red}Do not touch any keys during the packages are downloading!${reset}"

pacstrap /mnt base linux linux-firmware dhcpcd man-db

echo -e "${bold_white}All the packages were successfully downloaded!${reset}"

######################################################################################

step "Fstab"

echo ""
echo -e "Generating fstab..."

genfstab -U /mnt >> /mnt/etc/fstab

######################################################################################

step "Chroot"

chroot_script_cmd=$(curl -s https://raw.githubusercontent.com/NetherMCtv/ArchLinuxInstallationSetup/latest/scripts/chroot.sh; chmod +x ./chroot.sh)
arch-chroot /mnt "${chroot_script_cmd}"