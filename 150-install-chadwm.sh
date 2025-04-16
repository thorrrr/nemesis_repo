#!/bin/bash
#set -e
##################################################################################################################
# Author    : Dale Holden
# Purpose   : Installs ChadWM properly with session setup and build process
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

echo
tput setaf 3
echo "################################################################"
echo "################### Installing ChadWM Setup #####################"
echo "################################################################"
tput sgr0
echo

# Install required dependencies
sudo pacman -S --noconfirm --needed \
  base-devel xorg xorg-xinit xorg-xrandr xorg-xsetroot \
  sxhkd feh rofi picom kitty lxappearance \
  thunar flameshot pavucontrol volumeicon \
  arandr unzip unrar zip p7zip nitrogen \
  sddm

# Enable SDDM
sudo systemctl enable sddm.service

# Install yay if not installed
if ! command -v yay &>/dev/null; then
  echo "Installing yay..."
  git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
  cd /tmp/yay-git || exit 1
  makepkg -si --noconfirm
  cd ~
fi

# Commented out AUR apps for faster testing
# yay -S --noconfirm \
#   brave-beta-bin \
#   logseq-desktop-bin \
#   stacer-bin \
#   sublime-text-4 \
#   gitfiend \
#   zen-browser-bin \
#   bitwarden \
#   nextcloud \
#   espanso \
#   spotify \
#   lollypop \
#   parole-media-player \
#   vlc \
#   discord \
#   nomacs \
#   insync \
#   qbittorrent

# Clone your ChadWM config
echo "Cloning ChadWM config from your GitHub..."
rm -rf ~/.config/chadwm
mkdir -p ~/.config

# Use shallow clone to avoid auth issues
git clone --depth=1 https://github.com/thorrrr/dale-chadwn.git ~/.config/chadwm

# Build ChadWM
cd ~/.config/chadwm || exit 1
make clean
sudo make clean install

# Create SDDM session entry
echo "Creating ChadWM desktop session entry..."
sudo tee /usr/share/xsessions/chadwm.desktop >/dev/null <<EOF
[Desktop Entry]
Name=ChadWM
Comment=ChadWM window manager session
Exec=/usr/local/bin/chadwm-start
TryExec=/usr/local/bin/chadwm-start
Type=Application
DesktopNames=ChadWM
EOF

# Create the session startup script
echo "Creating /usr/local/bin/chadwm-start..."
sudo tee /usr/local/bin/chadwm-start >/dev/null <<EOF
#!/bin/bash
exec ~/.config/chadwm/autostart.sh
EOF

sudo chmod +x /usr/local/bin/chadwm-start

# Make sure your autostart is executable
chmod +x ~/.config/chadwm/autostart.sh 2>/dev/null || echo "Note: autostart.sh not found or not executable."

# Done
echo
tput setaf 2
echo "################################################################"
echo "################### ChadWM Setup Complete #######################"
echo "################################################################"
tput sgr0
echo
echo "✅ Reboot and select ChadWM from the SDDM login menu."
