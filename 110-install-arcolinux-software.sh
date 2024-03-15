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
echo "################### ArcoLinux Software to install"
echo "################################################################"
tput sgr0
echo

if grep -q arcolinux_repo /etc/pacman.conf; then

  echo
  tput setaf 2
  echo "################################################################"
  echo "################ ArcoLinux repos are already in /etc/pacman.conf "
  echo "################################################################"
  tput sgr0
  echo
  else
  echo
  tput setaf 2
  echo "################################################################"
  echo "################### Getting the keys and mirrors for ArcoLinux"
  echo "################################################################"
  tput sgr0
  echo
  sh arch/get-the-keys-and-repos.sh
  sudo pacman -Sy
fi

sudo pacman -S --noconfirm --needed a-candy-beauty-icon-theme-git
sudo pacman -S --noconfirm --needed arcolinux-app-glade-git
sudo pacman -S --noconfirm --needed arcolinux-hblock-git
sudo pacman -S --noconfirm --needed archlinux-tweak-tool-git
sudo pacman -S --noconfirm --needed arcolinux-wallpapers-git

if [ ! -f /usr/share/wayland-sessions/plasma.desktop ]; then
  sudo pacman -S --noconfirm --needed archlinux-logout-git
  sudo pacman -S --noconfirm --needed arcolinux-arc-dawn-git
fi

###############################################################################

# when on Plasma X11

if [ -f /usr/bin/startplasma-x11 ]; then

  echo
  tput setaf 2
  echo "################################################################"
  echo "################### Plasma X11 related applications"
  echo "################################################################"
  tput sgr0
  echo

  #sudo pacman -S --noconfirm --needed arcolinux-plasma-arc-dark-candy-git
  #sudo pacman -S --noconfirm --needed arcolinux-plasma-nordic-darker-candy-git
  #sudo pacman -S --noconfirm --needed surfn-plasma-dark-icons-git
  #sudo pacman -S --noconfirm --needed surfn-plasma-light-icons-git
fi

# when on Plasma Wayland

if [ -f /usr/share/wayland-sessions/plasma.desktop ]; then

  echo
  tput setaf 2
  echo "################################################################"
  echo "################### Plasma wayland related applications"
  echo "################################################################"
  tput sgr0
  echo
  sudo pacman -S --noconfirm --needed surfn-plasma-dark-icons-git
  sudo pacman -S --noconfirm --needed surfn-plasma-light-icons-git
fi


if [ -f /usr/share/xsessions/xfce.desktop ]; then

  echo
  tput setaf 2
  echo "################################################################"
  echo "################### Installing software for Xfce"
  echo "################################################################"
  tput sgr0
  echo

  sudo pacman -S --noconfirm --needed arcolinux-arc-kde

fi

if [ -f /usr/share/xsessions/cinnamon.desktop ]; then

  echo
  tput setaf 2
  echo "################################################################"
  echo "################### Installing software for Cinnamon"
  echo "################################################################"
  tput sgr0
  echo

  sudo pacman -S --noconfirm --needed nemo-fileroller
  sudo pacman -S --noconfirm --needed cinnamon-translations
  sudo pacman -S --noconfirm --needed mintlocale
  sudo pacman -S --noconfirm --needed iso-flag-png
  sudo pacman -S --noconfirm --needed gnome-terminal
  sudo pacman -S --noconfirm --needed gnome-system-monitor
  sudo pacman -S --noconfirm --needed gnome-screenshot
  sudo pacman -S --noconfirm --needed xed

fi

echo
tput setaf 6
echo "################################################################"
echo "################### Done"
echo "################################################################"
tput sgr0
echo