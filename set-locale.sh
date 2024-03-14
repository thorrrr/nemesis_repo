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

#sudo localectl set-keymap be-latin1
#sudo localectl set-locale LANG=en_GB.UTF-8
echo
tput setaf 2
echo "################################################################"
echo "################### Done"
echo "################################################################"
tput sgr0
echo

echo
tput setaf 2
echo "################################################################"
echo "################### rebooting now after 5 seconds"
echo "Press CTRL +C to stop script"
echo "################################################################"
tput sgr0
echo

sleep 5

sudo reboot