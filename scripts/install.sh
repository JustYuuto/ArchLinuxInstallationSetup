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
    sleep 5
    clear

    name=$1
    line=""

    for (( i=0; i<${#name}; i++ )) ; do
        line+="="
    done

    echo -e "${bold_white}${name}${reset}"
    echo $line
    echo ""
}

question () {
    echo -e "${bold_white}> ${reset}$1"
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

echo -e "${bold_white}Disks list:${reset}"
lsblk

echo ""
echo -e "${bold_red}WARNING: THE DISK WILL BE FORMATED! ALL DATA ON IT WILL BE LOST!${reset}"
question "On which disk do you want to install Arch Linux?"
while true ; do
    read -t 9999999 disk
    case $disk in
        "/dev/sd"* | "/dev/nvme"*) selected=1; break;;
        *) echo -e "${bold_red}The selected disk does not exist! ${red}Please choose another disk.${reset}"; selected=0; ;;
    esac
done

echo ""

echo -e "Partitionning ${bold_white}${disk}${reset}..."

if [ $is_uefi == 1 ] ; then
    parted $disk mklabel gpt
else
    parted $disk mklabel msdos # mbr
fi

# ESP               Type    Filesystem  Start  End
parted $disk mkpart primary fat32       1M     300M
parted $disk set 1 esp on

# Swap partition (4G)
parted $disk mkpart primary linux-swap  300M   4396M

# FS
parted $disk mkpart primary ext4        4396M  100%

echo -e "Disk successfully partitionned without errors."

echo -e "Formatting partitions..."
mkfs.ext4 "${disk}3"
mkswap "${disk}2"
mkfs.fat -F 32 "${disk}1"

echo -e "Mounting ${bold_white}${disk}3${reset} (FS) to ${bold_white}/mnt${reset}..."
mount "${disk}3" /mnt

echo -e "Mounting ${bold_white}${disk}1${reset} (ESP) to ${bold_white}/mnt/boot${reset}..."
mount --mkdir "${disk}1" /mnt/boot

swapon "${disk}2"

######################################################################################

step "Packages installation"

echo -e "${bold_red}Do not touch any keys during the packages are downloading!${reset}"

pacstrap /mnt base linux linux-firmware dhcpcd man-db

echo -e "${bold_white}All the packages were successfully downloaded!${reset}"

######################################################################################

step "Fstab"

echo -e "Generating fstab..."

genfstab -U /mnt >> /mnt/etc/fstab

echo -e "Fstab generated"

######################################################################################

step "Chroot"

curl -s https://raw.githubusercontent.com/NetherMCtv/ArchLinuxInstallationSetup/latest/scripts/chroot.sh -o chroot.sh
chmod +x ./chroot.sh
arch-chroot /mnt "$HOME/chroot.sh"