#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden
# Script    : Install ChadWM + full app stack (clean version)
##################################################################################################################

DRY_RUN=false  # Set to true for testing only

##################################################################################################################
# Functions
##################################################################################################################

func_clone_and_build_chadwm() {
    echo; tput setaf 4
    echo "🌐 Cloning ChadWM repo from GitHub via SSH and preparing setup..."
    tput sgr0

    local target_dir=~/.config/chadwm-git

    if [[ "$DRY_RUN" = false ]]; then
        rm -rf "$target_dir"
        git clone --depth=1 git@github.com:thorrrr/dale-chadwn.git "$target_dir" || {
            echo "❌ Failed to clone ChadWM repo"
            exit 1
        }
    else
        echo "🔎 DRY RUN: Would clone to $target_dir"
    fi

    # Optional: run script inside repo if needed
    if [[ -x "$target_dir/scripts/install-chadwm.sh" ]]; then
        chmod +x "$target_dir/scripts/install-chadwm.sh"
        [[ "$DRY_RUN" = false ]] && "$target_dir/scripts/install-chadwm.sh" || echo "🔎 DRY RUN: Would run install-chadwm.sh"
    else
        echo "⚠️ No install-chadwm.sh found inside $target_dir/scripts/"
    fi
}

func_install_apps() {
    echo; tput setaf 2
    echo "################################################################"
    echo "################### Installing core apps"
    echo "################################################################"
    tput sgr0; echo

    local list=(
        a-candy-beauty-icon-theme-git
        alacritty
        archlinux-logout-git
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

    local aur_list=(
        brave-beta-bin
        zen-browser-bin
        logseq-desktop-bin
        stacer-bin
        yay-git
        syncthing
    )

    local count=1
    for pkg in "${list[@]}"; do
        echo "[$count/${#list[@]}] $pkg"
        func_install "$pkg"
        ((count++))
    done

    echo; tput setaf 6
    echo "🔽 Installing AUR packages (via paru)"
    tput sgr0

    for pkg in "${aur_list[@]}"; do
        func_install_aur "$pkg"
    done
}

func_clone_and_build_chadwm() {
    echo; tput setaf 4
    echo "🌐 Cloning ChadWM from GitHub and building..."
    tput sgr0

    if [[ "$DRY_RUN" = false ]]; then
        rm -rf ~/chadwm-laptop
        git clone https://github.com/thorrrr/chadwm-laptop ~/chadwm-laptop || {
            echo "❌ Failed to clone ChadWM repo"
            exit 1
        }
    else
        echo "🔎 DRY RUN: Skipping clone. Checking if repo exists..."
        [[ -d ~/chadwm-laptop ]] && echo "✔ Repo exists" || echo "❌ Repo not found"
    fi

    cd ~/chadwm-laptop/scripts || {
        echo "❌ Script folder not found"
        exit 1
    }

    chmod +x install-chadwm.sh
    [[ "$DRY_RUN" = false ]] && ./install-chadwm.sh || echo "🔎 DRY RUN: Would run install-chadwm.sh"
}

##################################################################################################################
# Run
##################################################################################################################

tput setaf 2
echo
echo "################################################################"
echo "### Running 150-install-chadwm.sh"
echo "################################################################"
tput sgr0

func_install_apps
func_clone_and_build_chadwm

echo; tput setaf 6
echo "🔎 Verifying key tools:"
for bin in ghostty logseq brave-browser btop; do
    command -v "$bin" &>/dev/null && echo "✔ $bin found" || echo "❌ $bin missing"
done
tput sgr0

echo
tput setaf 6
echo "######################################################"
echo "################### Script complete"
echo "######################################################"
tput sgr0
