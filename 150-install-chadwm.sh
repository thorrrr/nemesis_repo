#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden
# Script    : Install ChadWM + dependencies
##################################################################################################################

# Set DRY_RUN=true for testing what would be installed
DRY_RUN=true

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
        echo "✔ $1 is already installed"
        tput sgr0
    else
        tput setaf 3
        echo "➕ Installing: $1"
        tput sgr0
        if [[ "$DRY_RUN" = false ]]; then
            sudo pacman -S --noconfirm --needed "$1"
        fi
    fi
}

func_install_aur() {
    if pacman -Qm "$1" &>/dev/null; then
        tput setaf 2
        echo "✔ AUR: $1 is already installed"
        tput sgr0
    else
        tput setaf 5
        echo "➕ Installing AUR package: $1"
        tput sgr0
        if [[ "$DRY_RUN" = false ]]; then
            paru -S --noconfirm --needed "$1"
        fi
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
        ghostty
        gvfs
        lolcat
        lxappearance
        make
        mpv
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
        variety
        volumeicon
        xfce4-notifyd
        xfce4-power-manager
        xfce4-screenshooter
        xfce4-settings
        xfce4-taskmanager
        xfce4-terminal
        xorg-xsetroot
        sublime-text-4
        bitwarden
        nextcloud
        espanso
        tmux
        btop
        kitty
    )

    aur_list=(
        brave-beta-bin
        zen-browser-bin
        logseq-desktop-bin
        stacer-bin
        yay-git
        syncthing
    )

    count=1
    for name in "${list[@]}"; do
        echo "[$count/${#list[@]}] $name"
        func_install "$name"
        ((count++))
    done

    echo
    tput setaf 6
    echo "🔽 AUR packages (via paru)"
    tput sgr0
    for pkg in "${aur_list[@]}"; do
        func_install_aur "$pkg"
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
