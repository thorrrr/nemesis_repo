#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden (based on Erik Dubois' template)
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

if [ "$DEBUG" = true ]; then
    echo
    echo "------------------------------------------------------------"
    echo "Running $(basename $0)"
    echo "------------------------------------------------------------"
    echo
    read -n 1 -s -r -p "Debug mode is on. Press any key to continue..."
    echo
fi

##################################################################################################################

# software from AUR (Arch User Repositories)
# https://aur.archlinux.org/packages/

echo
tput setaf 2
echo "################################################################"
echo "################### AUR from folder - Software to install"
echo "################################################################"
tput sgr0
echo

##################################################################################################################
echo
tput setaf 2
echo "################################################################"
echo "################### Build from AUR"
echo "################################################################"
tput sgr0
echo

# ----------------------------------
# Install brave-beta-bin if not present
if ! pacman -Qi brave-beta-bin &>/dev/null; then
    yay -S brave-beta-bin --noconfirm
else
    echo "brave-beta-bin is already installed."
fi

# ----------------------------------
# Install espanso for correct display server (X11 or Wayland)
display_server=$(loginctl show-session "$(loginctl | awk '/tty/ { print $1 }')" -p Type | cut -d= -f2)

if [ "$display_server" = "wayland" ]; then
    if ! pacman -Qi espanso-wayland-bin &>/dev/null; then
        yay -S espanso-wayland-bin --noconfirm
    else
        echo "espanso-wayland-bin is already installed."
    fi
else
    if ! pacman -Qi espanso-x11-bin &>/dev/null; then
        yay -S espanso-x11-bin --noconfirm
    else
        echo "espanso-x11-bin is already installed."
    fi
fi

# ----------------------------------
# Install grub-btrfs-git if not present
if ! pacman -Qi grub-btrfs-git &>/dev/null; then
    yay -S grub-btrfs-git --noconfirm
else
    echo "grub-btrfs-git is already installed."
fi

# ----------------------------------
# Install signal-in-tray if not present
if ! pacman -Qi signal-in-tray &>/dev/null; then
    yay -S signal-in-tray --noconfirm
else
    echo "signal-in-tray is already installed."
fi

echo
tput setaf 6
echo "######################################################"
echo "###################  $(basename $0) done"
echo "######################################################"
tput sgr0
echo

