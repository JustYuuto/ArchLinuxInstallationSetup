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

step "Date and time"

question "What is your timezone?"
read timezone

ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime

hwclock --systohc

######################################################################################

step "Localization"

question "What lang will you use?"
read locale

sed -i "s/#${locale}.UTF-8 UTF-8/${locale}.UTF-8 UTF-8/g" /etc/locale.gen

echo ""

locale-gen

echo "Setting the system locale..."

echo "LANG=${locale}.UTF-8
LANGUAGE=${locale}.UTF-8
LC_ALL=${locale}.UTF-8" > /etc/locale.conf

localectl set-locale LANG=${locale}.UTF-8

######################################################################################

step "Hostname"

question "Enter the hostname desired:         user@${bold_white}hostname${reset}"
read hostname

echo "${hostname}" > /etc/hostname

######################################################################################

step "Root password"

echo "You need to set the root password."
passwd

######################################################################################

step "Bootloader"

cpu=$(grep -m 1 'model name' /proc/cpuinfo | cut -d ":" -f 2)

if [ cpu == " AMD"* ] ; then
  amdcpu=1
else
  amdcpu=0
fi

if [ amdcpu == 1 ] ; then
  echo "${bold_white}[${bold_blue}INFO${bold_white}]${reset} Setup detected you're using an AMD CPU. Before installing the bootloader, the \"amd-ucode\" package needs to be installed."
  pacman -S --noconfirm amd-ucode
fi

echo ""
echo "Currently, the setup use GRUB as the bootloader, and this is the only possibility. If you want to add a bootloader, create an issue: https://github.com/NetherMCtv/ArchLinuxInstallationSetup/issues"

echo ""
echo "Downloading and installing GRUB and OS-prober"

pacman -S --noconfirm grub os-prober efibootmgr

mkdir -p /boot/efi

mount -t vfat ${arch_disk} /boot/efi

mkdir -p /boot/efi/EFI

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Arch Linux" --recheck

sed -i "s/#GRUB_DISABLE_OS_PROBER=/${locale}.UTF-8 UTF-8/g" /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg