#!/bin/bash
set -e

echo
echo ">>> Installing Dale's ChadWM setup (mimicking ATT)"

# Install ONLY safe pacman packages (AUR ones must be handled separately)
sudo pacman -S --noconfirm --needed \
    alacritty arandr autorandr base-devel dash dmenu feh flameshot gcc git \
    gvfs lxappearance make nitrogen p7zip pavucontrol picom polkit-gnome \
    rofi sxhkd thunar thunar-archive-plugin thunar-volman ttf-hack \
    ttf-jetbrains-mono-nerd unrar unzip volumeicon xfce4-notifyd \
    xfce4-power-manager xfce4-screenshooter xfce4-settings xfce4-taskmanager \
    xfce4-terminal nano xorg xorg-xinit xorg-xrandr xorg-xsetroot zip

# Enable display manager
sudo systemctl enable sddm.service

# Clone your ChadWM setup
CHADWM_DIR="$HOME/.config/arco-chadwm"
rm -rf "$CHADWM_DIR"
git clone https://github.com/thorrrr/dale-chadwn.git "$CHADWM_DIR"

# Build ChadWM
cd "$CHADWM_DIR/chadwm"
make
sudo make clean install

# Create /usr/bin/exec-chadwm
sudo tee /usr/bin/exec-chadwm > /dev/null <<'EOF'
#!/bin/bash
pgrep -x sxhkd >/dev/null || sxhkd &
picom &
volumeicon &
xfce4-notifyd &
[ -f ~/Pictures/wallpaper.jpg ] && feh --bg-scale ~/Pictures/wallpaper.jpg &
exec chadwm
EOF

sudo chmod +x /usr/bin/exec-chadwm

# Create session entry for SDDM
sudo tee /usr/share/xsessions/chadwm.desktop > /dev/null <<'EOF'
[Desktop Entry]
Encoding=UTF-8
Name=Chadwm
Comment=Dynamic window manager
Exec=/usr/bin/exec-chadwm
Icon=chadwm
Type=Application
EOF

echo
echo "✅ ChadWM installed using your repo"
echo "➡️  Select 'Chadwm' in SDDM and login."
