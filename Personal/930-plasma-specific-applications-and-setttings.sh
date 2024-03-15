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


if [ -f /usr/bin/startplasma-x11 ]; then

	echo
	tput setaf 2
	echo "################################################################"
	echo "################### Plasma specific"
	echo "################################################################"
	tput sgr0
	echo

	echo
	tput setaf 2
	echo "################################################################"
	echo "################### Bookmarks plasma to be installed"
	echo "################################################################"
	tput sgr0
	echo

	cp $installed_dir/settings/plasma/bookmarks/user-places.xbel ~/.local/share/user-places.xbel
	
	echo
	tput setaf 2
	echo "################################################################"
	echo "################### Bookmarks plasma installed"
	echo "################################################################"
	tput sgr0

fi
