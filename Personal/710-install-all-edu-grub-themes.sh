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

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

##################################################################################################################

echo
tput setaf 2
echo "################################################################"
echo "################### Installing all EDU icons"
echo "################################################################"
tput sgr0
echo

sudo pacman -S --noconfirm --needed edu-alci-grub-theme-git
sudo pacman -S --noconfirm --needed edu-arcolinux-grub-theme-git
sudo pacman -S --noconfirm --needed edu-ariser-grub-theme-git
sudo pacman -S --noconfirm --needed edu-asus-grub-theme-git
sudo pacman -S --noconfirm --needed edu-bao-grub-theme-git
sudo pacman -S --noconfirm --needed edu-chadwm-grub-theme-git
sudo pacman -S --noconfirm --needed edu-evi-grub-theme-git
sudo pacman -S --noconfirm --needed edu-radar-grub-theme-git
sudo pacman -S --noconfirm --needed edu-radar-mono-grub-theme-git
sudo pacman -S --noconfirm --needed edu-ubuntu-grub-theme-git
sudo pacman -S --noconfirm --needed edu-vimix-mono-grub-theme-git

echo
tput setaf 2
echo "################################################################"
echo "################### Done"
echo "################################################################"
tput sgr0
echo