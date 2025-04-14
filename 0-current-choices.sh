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

#end colors
#tput sgr0
##################################################################################################################

#networkmanager issue
#nmcli connection modify Wired\ connection\ 1 ipv6.method "disabled"

# what is the present working directory
installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

##################################################################################################################

# set DEBUG to true to be able to analyze the scripts file per file
export DEBUG=false

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

run_script() {
    cd "Personal/settings/$1-chadwm/" || exit 1
    sh ./1-all-in-one.sh
    exit 1
}
if [ -f /etc/lsb-release ] && grep -q "MX 23.4" /etc/lsb-release; then
    run_script "mxlinux"
fi
if grep -q "bunsenlabs" /etc/os-release; then run_script "bunsenlabs"; fi
if grep -q "FreeBSD" /etc/os-release; then run_script "freebsd"; fi
if grep -q "GhostBSD" /etc/os-release; then run_script "ghostbsd"; fi
if grep -q "Debian" /etc/os-release; then run_script "debian"; fi
if grep -q "Peppermint" /etc/os-release; then run_script "peppermint"; fi
if grep -q "Pop!" /etc/os-release; then run_script "popos"; fi
if grep -q "LMDE 6" /etc/os-release; then run_script "lmde6"; fi
if grep -q "linuxmint" /etc/os-release; then run_script "mint"; fi
if grep -q "AlmaLinux" /etc/os-release; then run_script "almalinux"; fi
if grep -q "AnduinOS" /etc/os-release; then run_script "anduin"; fi
if grep -q "ubuntu" /etc/os-release; then run_script "ubuntu"; fi
if grep -q "void" /etc/os-release; then run_script "void"; fi
if grep -q "Nobara" /etc/os-release; then run_script "nobara"; fi
if grep -q "Fedora" /etc/os-release; then run_script "fedora"; fi
if grep -q "Solus" /etc/os-release; then run_script "solus"; fi

echo
tput setaf 3
echo "################################################################"
echo "Do you want to install Chadwm on your system?"
echo "Answer with Y/y or N/n"
echo "################################################################"
tput sgr0
echo

read response

if [[ "$response" == [yY] ]]; then
    touch /tmp/install-chadwm
fi

if grep -q 'arcolinux_repo' /etc/pacman.conf && \
   grep -q 'arcolinux_repo_3party' /etc/pacman.conf; then

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

# only for arcoinstall
if grep -q 'arcoinstall' /etc/pacman.conf ;then
  sudo cp /etc/pacman.conf /etc/pacman.conf.backup
  sudo wget https://raw.githubusercontent.com/arconetpro/arconet-iso/refs/heads/main/archiso/airootfs/etc/pacman.conf -O /etc/pacman.conf
fi

# only for ArchBang
sh 410-intervention*

# Check if arcolinux-repos etc are there
if ! pacman -Qi arcolinux-keyring &> /dev/null; then
    sh arch/get-the-keys-and-repos.sh
    sudo pacman -Syyu
fi

sudo pacman -S sublime-text-4 --noconfirm --needed
sudo pacman -S ripgrep --noconfirm --needed
sudo pacman -S meld --noconfirm --needed

echo
tput setaf 3
echo "################################################################"
echo "################### Pacman parallel downloads to 22"
echo "################################################################"
tput sgr0
echo

sudo sed -i 's/^#*ParallelDownloads = .*/ParallelDownloads = 22/' /etc/pacman.conf

echo
tput setaf 3
echo "################################################################"
echo "################### Start current choices"
echo "################################################################"
tput sgr0
echo

sudo pacman -Sy

if [ -f /etc/dev-rel ]; then

    if grep -q "arconet" /etc/dev-rel || grep -q "arcopro" /etc/dev-rel || grep -q "arcoplasma" /etc/dev-rel; then
        echo
        tput setaf 3
        echo "################################################################"
        echo "######## We are either on arconet, arcopro or arcoplasma"
        echo "################################################################"
        tput sgr0
        echo
        sh get-me-started
    fi
fi

sh 400-remove-software*

sh 100-install-nemesis-software*
sh 110-install-arcolinux-software*
sh 120-install-core-software*
sh 150-install-chadwm*
sh 160-install-bluetooth*
sh 170-install-cups*
#sh 180-install-test-software*

sh 200-software-AUR-repo*
sh 500-*

echo
tput setaf 3
echo "################################################################"
echo "################### Going to the Personal folder"
echo "################################################################"
tput sgr0
echo

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))
cd $installed_dir/Personal

sh 900-*
sh 910-*
sh 920-*
sh 930-*
sh 940-*
sh 950-*

sh 960-*

sh 969-skel*

sh 970-all*

sh 970-alci*
sh 970-archman*
sh 970-archcraft*
sh 970-arco*
sh 970-ariser*
sh 970-carli*
sh 970-eos*
sh 970-garuda*
sh 970-sierra*
sh 970-biglinux*
sh 970-rebornos*
sh 970-archbang*
sh 970-manjaro*

#has to be last - they are all Arch
sh 970-arch.sh

sh 999-what*

tput setaf 3
echo "################################################################"
echo "End current choices"
echo "################################################################"
tput sgr0
