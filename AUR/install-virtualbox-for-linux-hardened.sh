#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
#tput setaf 0 = black
#tput setaf 1 = red
#tput setaf 2 = green
#tput setaf 3 = yellow
#tput setaf 4 = dark blue
#tput setaf 5 = purple
#tput setaf 6 = cyan
#tput setaf 7 = gray
#tput setaf 8 = light blue
##################################################################################################################

echo "###########################################################################"
echo "##      This script assumes you have the linux-hardened kernel running        ##"
echo "###########################################################################"

sudo pacman -S --noconfirm --needed virtualbox
sudo pacman -S --noconfirm --needed linux-hardened-headers
sudo pacman -S --needed virtualbox-host-dkms

echo "###########################################################################"
echo "##      Removing all the messages virtualbox produces         ##"
echo "###########################################################################"
VBoxManage setextradata global GUI/SuppressMessages "all"

# resolution issues Jan/2023
# VBoxManage setextradata "Your Virtual Machine Name" "VBoxInternal2/EfiGraphicsResolution" "2560x1440"
# VBoxManage setextradata "Your Virtual Machine Name" "VBoxInternal2/EfiGraphicsResolution" "1920x1080"
# graphical driver - VMSVGA !
# see : https://wiki.archlinux.org/title/VirtualBox#Set_guest_starting_resolution

echo "###########################################################################"
echo "#########               You have to reboot.                       #########"
echo "###########################################################################"
