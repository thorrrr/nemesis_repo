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
sudo pacman -S --noconfirm --needed \
  kitty rofi sxhkd neofetch btop fastfetch \
  thunar file-roller gvfs gvfs-smb \
  flameshot mpv picom lxappearance \
  volumeicon pavucontrol feh nitrogen \
  arandr unzip unrar zip p7zip \
  bitwarden nextcloud espanso \
  xorg xorg-xinit xorg-xrandr xorg-xsetroot \
  sddm

# Enable SDDM
echo "Enabling SDDM..."
sudo systemctl enable sddm.service

# Installing AUR apps using yay
if ! command -v yay &>/dev/null; then
  echo "Installing yay..."
  git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
  cd /tmp/yay-git || exit
  makepkg -si --noconfirm --needed
  cd ~
fi

# Ensure yay won’t ask for password during batch install
export MAKEPKG="makepkg --skippgpcheck"

echo "Installing AUR apps via yay..."
yay -S --noconfirm --needed \
  brave-beta-bin \
  logseq-desktop-bin \
  stacer-bin \
  sublime-text-4 \
  gitfiend \
  zen-browser-bin

# Clone Dale’s custom ChadWM config
mkdir -p ~/.config
rm -rf ~/.config/chadwm

echo "Cloning ChadWM config from Dale’s GitHub..."
git clone --depth=1 https://github.com/thorrrr/dale-chadwn.git /tmp/chadwm-temp
mv /tmp/chadwm-temp/chadwm ~/.config/chadwm
rm -rf /tmp/chadwm-temp

# Build ChadWM if Makefile exists
if [ -f ~/.config/chadwm/Makefile ]; then
  echo "Building ChadWM with make..."
  cd ~/.config/chadwm || exit
  make && sudo make clean install
else
  echo "Makefile not found in ~/.config/chadwm. Build failed."
fi

# Set up XSession entry for ChadWM (for SDDM)
echo "Creating ChadWM desktop entry..."
echo "[Desktop Entry]
Name=ChadWM
Comment=ChadWM window manager session
Exec=/usr/local/bin/chadwm-start
TryExec=/usr/local/bin/chadwm-start
Type=Application
X-SDDM-DesktopName=ChadWM
DesktopNames=ChadWM" | sudo tee /usr/share/xsessions/chadwm.desktop > /dev/null

# Create launcher script for session startup
echo "#!/bin/bash
exec ~/.config/chadwm/autostart.sh" | sudo tee /usr/local/bin/chadwm-start > /dev/null
sudo chmod +x /usr/local/bin/chadwm-start

# Fallback: create a basic autostart.sh if missing
if [ ! -f ~/.config/chadwm/autostart.sh ]; then
  echo "#!/bin/bash
sxhkd &
bars &
exec chadwm" > ~/.config/chadwm/autostart.sh
fi

chmod +x ~/.config/chadwm/autostart.sh

# Final message
echo

tput setaf 2
  echo "################################################################"
  echo "################### ChadWM Setup Complete #######################"
  echo "################################################################"
tput sgr0

echo "Reboot your system and select 'ChadWM' from the SDDM login menu."