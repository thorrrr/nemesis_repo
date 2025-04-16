#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
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

echo

tput setaf 3
  echo "################################################################"
  echo "################### Installing ChadWM Setup #####################"
  echo "################################################################"
tput sgr0

echo "Installing required packages from official repos..."
sudo pacman -S --noconfirm \
  kitty rofi sxhkd neofetch btop fastfetch \
  thunar file-roller gvfs gvfs-smb \
  flameshot mpv picom lxappearance \
  volumeicon pavucontrol feh nitrogen \
  arandr unzip unrar zip p7zip \
  bitwarden nextcloud espanso \
  xorg xorg-xinit xorg-xrandr xorg-xsetroot \
  sddm

# Enable SDDM
sudo systemctl enable sddm.service

# Installing AUR apps using yay
if ! command -v yay &>/dev/null; then
  echo "Installing yay..."
  git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
  cd /tmp/yay-git || exit
  makepkg -si --noconfirm
  cd ~
fi

echo "Installing AUR apps via yay..."
yay -S --noconfirm \
  brave-beta-bin \
  logseq-desktop-bin \
  stacer-bin \
  sublime-text-4 \
  gitfiend \
  zen-browser-bin 

# Clone Dale’s custom ChadWM config
mkdir -p ~/.config
rm -rf ~/.config/chadwm-git

echo "Cloning ChadWM config from Dale’s GitHub..."
git clone git@github.com:thorrrr/dale-chadwn.git ~/.config/chadwm-git

# Build ChadWM
cd ~/.config/chadwm-git || exit
chmod +x install.sh
./install.sh

# Set up XSession entry for ChadWM (for SDDM)
echo "Creating ChadWM desktop entry..."
echo "[Desktop Entry]
Name=ChadWM
Comment=ChadWM window manager session
Exec=/usr/local/bin/chadwm-start
TryExec=/usr/local/bin/chadwm-start
Type=Application
X-LightDM-DesktopName=ChadWM
DesktopNames=ChadWM" | sudo tee /usr/share/xsessions/chadwm.desktop > /dev/null

# Create launcher script for session startup
echo "#!/bin/bash
exec ~/.config/chadwm-git/autostart.sh" | sudo tee /usr/local/bin/chadwm-start > /dev/null
sudo chmod +x /usr/local/bin/chadwm-start

# Fix permissions on autostart script if needed
chmod +x ~/.config/chadwm-git/autostart.sh

# Final message
echo

tput setaf 2
  echo "################################################################"
  echo "################### ChadWM Setup Complete #######################"
  echo "################################################################"
tput sgr0

echo "Reboot your system and select 'ChadWM' from the SDDM login menu."
