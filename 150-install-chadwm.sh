#!/bin/bash
set -e

echo
echo ">>> Installing Dale's ChadWM setup (like ATT but from your repo)"

# 1. Install core packages (exact match to ATT output)
sudo pacman -S --noconfirm --needed \
    alacritty arcolinux-logout-git arcolinux-powermenu-git arcolinux-rofi-git \
    arcolinux-rofi-themes-git arcolinux-volumeicon-git arcolinux-root-git \
    dmenu feh gvfs lxappearance picom-git polkit-gnome rofi-lbonn-wayland \
    sxhkd thunar thunar-archive-plugin thunar-volman ttf-hack \
    ttf-jetbrains-mono-nerd ttf-meslo-nerd-font-powerlevel10k \
    volumeicon xfce4-notifyd xfce4-power-manager xfce4-screenshooter \
    xfce4-settings xfce4-taskmanager xfce4-terminal nano

# 2. Enable SDDM
sudo systemctl enable sddm.service

# 3. Clone YOUR ChadWM setup
CHADWM_DIR="$HOME/.config/arco-chadwm"
rm -rf "$CHADWM_DIR"
git clone https://github.com/thorrrr/dale-chadwn.git "$CHADWM_DIR"

# 4. Build ChadWM
cd "$CHADWM_DIR/chadwm"
make
sudo make clean install

# 5. Create launch script
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

# 6. Create SDDM session
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
echo "✅ ChadWM installed from: https://github.com/thorrrr/dale-chadwn.git"
echo "➡️ Select 'ChadWM' from SDDM after reboot."
