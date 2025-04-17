#!/bin/bash
##################################################################################################################
# Author     : Dale Holden
# Purpose    : Installs Dale's ChadWM version from Git, sets up session and build process.
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

func_install() {
    if pacman -Qi $1 &> /dev/null; then
        tput setaf 2
        echo "###############################################################################"
        echo "################## Package \"$1\" is already installed"
        echo "###############################################################################"
        echo
        tput sgr0
    else
        tput setaf 3
        echo "###############################################################################"
        echo "##################  Installing package "  $1
        echo "###############################################################################"
        echo
        tput sgr0
        sudo pacman -S --noconfirm --needed $1 || {
            tput setaf 1
            echo "!!! Error installing package $1. Please check pacman output/logs."
            tput sgr0
            exit 1
        }
    fi
}

echo
printf "\e[33m################################################################\e[0m\n"
echo "################### Installing Dale's ChadWM Setup ##############"
printf "\e[33m################################################################\e[0m\n"
echo

echo "Installing dependencies..."
list=(
    alacritty arandr autorandr base-devel dash dmenu feh flameshot gcc git
    gvfs lxappearance make nitrogen p7zip pavucontrol picom polkit-gnome
    rofi sddm sxhkd thunar thunar-archive-plugin thunar-volman ttf-hack
    ttf-jetbrains-mono-nerd unrar unzip volumeicon xfce4-notifyd
    xfce4-power-manager xorg xorg-xinit xorg-xrandr xorg-xsetroot zip
)

count=0
for name in "${list[@]}" ; do
    count=$[count+1]
    echo "Installing package nr. $count  $name"
    func_install $name
done

sudo systemctl enable sddm.service || {
    tput setaf 1
    echo "!!! Error enabling SDDM. Check sudo permissions or logs."
    tput sgr0
}

USER_CHADWM_REPO_URL="https://github.com/thorrrr/dale-chadwn.git"
CHADWM_CONFIG_DIR="$HOME/.config/arco-chadwm"

rm -rf "$CHADWM_CONFIG_DIR"
echo "Cloning ChadWM repo to $CHADWM_CONFIG_DIR..."
git clone --depth=1 "$USER_CHADWM_REPO_URL" "$CHADWM_CONFIG_DIR" || {
    tput setaf 1
    echo "!!! Git clone failed"
    tput sgr0
    exit 1
}

if [ -d "$CHADWM_CONFIG_DIR/dale-chadwn" ]; then
    mv "$CHADWM_CONFIG_DIR/dale-chadwn"/* "$CHADWM_CONFIG_DIR"/
    rm -rf "$CHADWM_CONFIG_DIR/dale-chadwn"
fi

rm -f "$CHADWM_CONFIG_DIR/README.md" "$CHADWM_CONFIG_DIR/setup-git.sh" "$CHADWM_CONFIG_DIR/up.sh"

CHADWM_BUILD_DIR="$CHADWM_CONFIG_DIR/chadwm"
echo "Building ChadWM from $CHADWM_BUILD_DIR..."

if [ ! -f "$CHADWM_BUILD_DIR/Makefile" ]; then
    tput setaf 1
    echo "!!! Makefile not found. Build folder missing?"
    tput sgr0
    exit 1
fi

cd "$CHADWM_BUILD_DIR"
make || {
    tput setaf 1
    echo "!!! Build failed"
    tput sgr0
    exit 1
}
sudo make clean install || {
    tput setaf 1
    echo "!!! Install failed"
    tput sgr0
    exit 1
}

cat > /tmp/chadwm.desktop <<EOF
[Desktop Entry]
Name=ChadWM
Comment=Dale's ChadWM session
Exec=/usr/local/bin/chadwm-start
TryExec=/usr/local/bin/chadwm-start
Type=Application
DesktopNames=Chadwm;ChadWM
EOF
sudo cp /tmp/chadwm.desktop /usr/share/xsessions/chadwm.desktop
rm /tmp/chadwm.desktop

cat > /tmp/chadwm-start <<EOF
#!/bin/bash
exec \$HOME/.config/arco-chadwm/autostart.sh
EOF
sudo cp /tmp/chadwm-start /usr/local/bin/chadwm-start
sudo chmod +x /usr/local/bin/chadwm-start
rm /tmp/chadwm-start

AUTOSTART_SCRIPT="$CHADWM_CONFIG_DIR/autostart.sh"

# Force rewrite autostart.sh with environment detection
cat > "$AUTOSTART_SCRIPT" <<'EOF'
#!/bin/bash

SESSION_DESKTOP=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

if [[ "$SESSION_DESKTOP" != *chadwm* ]]; then
    echo "Not launching ChadWM autostart because session is: $SESSION_DESKTOP"
    exit 0
fi

sxhkd &
picom &
volumeicon &
xfce4-notifyd &
feh --bg-scale ~/Pictures/wallpaper.jpg &
exec chadwm
EOF

chmod +x "$AUTOSTART_SCRIPT"

rm -f ~/.xinitrc ~/.xsession 2>/dev/null

echo
printf "\e[32m################################################################\e[0m\n"
echo "################### Dale's ChadWM Setup Complete ################"
printf "\e[32m################################################################\e[0m\n"
echo

echo "✅ Built from: $CHADWM_BUILD_DIR"
echo "✅ SDDM session: /usr/share/xsessions/chadwm.desktop"
echo "✅ Launch script: /usr/local/bin/chadwm-start"
echo "➡️ Reboot and select 'ChadWM' in SDDM login screen."
