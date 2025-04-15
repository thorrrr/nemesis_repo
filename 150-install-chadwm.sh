#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden
# Script    : Install ChadWM + dependencies
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

# tput setaf colors for reference
# 0 = black, 1 = red, 2 = green, 3 = yellow, 4 = dark blue, 5 = purple, 6 = cyan, 7 = gray

installed_dir=$(dirname "$(readlink -f "$(basename "$(pwd)")")")

##################################################################################################################
# DEBUG MODE
##################################################################################################################

if [[ "$DEBUG" = true ]]; then
    echo
    echo "------------------------------------------------------------"
    echo "Running $(basename "$0")"
    echo "------------------------------------------------------------"
    echo
    read -n 1 -s -r -p "Debug mode is on. Press any key to continue..."
    echo
fi

##################################################################################################################
# Functions
##################################################################################################################

func_install() {
    if pacman -Qi "$1" &>/dev/null; then
        tput setaf 2
        echo "###############################################################################"
        echo "################## The package \"$1\" is already installed"
        echo "###############################################################################"
        tput sgr0
    else
        tput setaf 3
        echo "###############################################################################"
        echo "################## Installing package \"$1\""
        echo "###############################################################################"
        tput sgr0
        sudo pacman -S --noconfirm --needed "$1"
    fi
}

func_install_chadwm() {
    echo
    tput setaf 2
    echo "################################################################"
    echo "################### Installing ChadWM + Components"
    echo "################################################################"
    tput sgr0
    echo

    list=(
        a-candy-beauty-icon-theme-git
        alacritty
        archlinux-logout-git
        arcolinux-chadwm-git
        arcolinux-chadwm-pacman-hook-git
        arcolinux-nlogout-git
        arcolinux-powermenu-git
        arcolinux-wallpapers-candy-git
        arcolinux-wallpapers-git
        arconet-xfce
        autorandr
        dash
        dmenu
        eww
        feh
        gcc
        gvfs
        lolcat
        lxappearance
        make
        picom
        polkit-gnome
        rofi-lbonn-wayland
        sxhkd
        thunar
        thunar-archive-plugin
        thunar-volman
        ttf-hack
        ttf-jetbrains-mono-nerd
        ttf-meslo-nerd-font-powerlevel10k
        volumeicon
        xfce4-notifyd
        xfce4-power-manager
        xfce4-screenshooter
        xfce4-settings
        xfce4-taskmanager
        xfce4-terminal
        xorg-xsetroot
    )

    count=1
    for name in "${list[@]}"; do
        tput setaf 3
        echo "[$count/${#list[@]}] Installing: $name"
        tput sgr0
        func_install "$name"
        ((count++))
    done
}

##################################################################################################################
# Trigger installation if marker file exists
##################################################################################################################

if [[ -f /tmp/install-chadwm ]]; then
    tput setaf 2
    echo
    echo "################################################################"
    echo "### Proceeding with ChadWM installation"
    echo "################################################################"
    tput sgr0
    func_install_chadwm
else
    tput setaf 1
    echo "❌ Skipping ChadWM install — /tmp/install-chadwm marker not found."
    tput sgr0
fi

echo
tput setaf 6
echo "######################################################"
echo "################### $(basename "$0") complete"
echo "######################################################"
tput sgr0
