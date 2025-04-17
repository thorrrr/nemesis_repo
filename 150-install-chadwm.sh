#!/bin/bash
##################################################################################################################
# Author     : Dale Holden
# Purpose    : Installs Dale's ChadWM version from Git, sets up session and build process.
##################################################################################################################

# Exit immediately if a command exits with a non-zero status.
# set -e # Uncomment this for stricter error checking if desired

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
# Colors for better output
# tput setaf 1 = red
# tput setaf 2 = green
# tput setaf 3 = yellow
# tput setaf 6 = cyan
# tput sgr0 = reset color

##################################################################################################################
# Function to check if package is installed and install if needed

func_install() {
    if pacman -Qi $1 &> /dev/null; then
        tput setaf 2
        echo "###############################################################################"
        echo "################## Package "$1" is already installed"
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
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "!!! Error installing package $1. Please check pacman output/logs."
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            tput sgr0
            exit 1
        }
    fi
}

echo
tput setaf 3
echo "################################################################"
echo "################### Installing Dale's ChadWM Setup ##############"
echo "################################################################"
tput sgr0
echo

# Install required dependencies
echo
tput setaf 2
echo "################################################################"
echo "################### Installing dependencies"
echo "################################################################"
tput sgr0
echo

list=(
    alacritty arandr autorandr base-devel dash dmenu feh flameshot gcc git
    gvfs kitty lxappearance make nitrogen p7zip pavucontrol picom polkit-gnome
    rofi sddm sxhkd thunar thunar-archive-plugin thunar-volman ttf-hack
    ttf-jetbrains-mono-nerd unrar unzip volumeicon xfce4-notifyd
    xfce4-power-manager xorg xorg-xinit xorg-xrandr xorg-xsetroot zip
)

count=0
for name in "${list[@]}" ; do
    count=$[count+1]
    tput setaf 3
    echo "Installing package nr. "$count " " $name
    tput sgr0
    func_install $name
done

echo "Enabling SDDM service..."
sudo systemctl enable sddm.service || {
    tput setaf 1
    echo "!!! Error enabling SDDM. Check sudo permissions or logs."
    tput sgr0
}

USER_CHADWM_REPO_URL="https://github.com/thorrrr/dale-chadwn.git"
CHADWM_CONFIG_DIR="$HOME/.config/arco-chadwm"

echo "Cleaning up existing target installation: $CHADWM_CONFIG_DIR"
rm -rf "$CHADWM_CONFIG_DIR"

echo "Cloning your ChadWM repository from $USER_CHADWM_REPO_URL..."
if ! command -v git &>/dev/null; then echo "Error: git command not found."; exit 1; fi

git clone --depth=1 "$USER_CHADWM_REPO_URL" "$CHADWM_CONFIG_DIR" || {
    tput setaf 1
    echo "!!! Error cloning your ChadWM repository from $USER_CHADWM_REPO_URL"
    tput sgr0
    exit 1
}

SOURCE_METHOD="Cloned to ~/.config/arco-chadwm"
echo "Repository cloned successfully to $CHADWM_CONFIG_DIR"
ls -la "$CHADWM_CONFIG_DIR"

CHADWM_BUILD_DIR="$CHADWM_CONFIG_DIR/chadwm"

echo "Attempting to build ChadWM from $CHADWM_BUILD_DIR..."

if [ ! -d "$CHADWM_BUILD_DIR" ]; then
    tput setaf 1
    echo "Error: Build directory $CHADWM_BUILD_DIR not found after cloning."
    tput sgr0
    exit 1
fi

if [ -f "$CHADWM_BUILD_DIR/Makefile" ]; then
    cd "$CHADWM_BUILD_DIR" || exit 1
    echo "Building ChadWM in $(pwd)..."

    make || {
        tput setaf 1
        echo "!!! Error: ChadWM 'make' (build) failed."
        tput sgr0
        exit 1
    }

    sudo make clean install || {
        tput setaf 1
        echo "!!! Error: ChadWM 'sudo make clean install' failed."
        tput sgr0
        exit 1
    }
else
    tput setaf 1
    echo "Error: Makefile not found in $CHADWM_BUILD_DIR. Cannot build."
    tput sgr0
    exit 1
fi

echo "Creating ChadWM desktop session entry..."
cat > /tmp/chadwm.desktop <<EOF
[Desktop Entry]
Name=DaleChadWM
Comment=Dale's ChadWM window manager session
Exec=/usr/local/bin/chadwm-start
TryExec=/usr/local/bin/chadwm-start
Type=Application
DesktopNames=DaleChadWM;ChadWM
EOF
sudo cp /tmp/chadwm.desktop /usr/share/xsessions/dale-chadwm.desktop || {
    tput setaf 1
    echo "!!! Error copying dale-chadwm.desktop."
    tput sgr0
}
rm /tmp/chadwm.desktop

echo "Creating /usr/local/bin/chadwm-start..."
cat > /tmp/chadwm-start <<EOF
#!/bin/bash
exec $HOME/.config/arco-chadwm/chadwm/autostart.sh
EOF
sudo cp /tmp/chadwm-start /usr/local/bin/chadwm-start || { echo "Error copying chadwm-start"; exit 1; }
sudo chmod +x /usr/local/bin/chadwm-start || { echo "Error setting execute permission on chadwm-start"; exit 1; }
rm /tmp/chadwm-start

AUTOSTART_SCRIPT="$CHADWM_CONFIG_DIR/chadwm/autostart.sh"
if [ -f "$AUTOSTART_SCRIPT" ]; then
    echo "Making your autostart.sh executable: $AUTOSTART_SCRIPT"
    chmod +x "$AUTOSTART_SCRIPT"
else
    tput setaf 3
    echo "!!! Warning: Autostart script not found at $AUTOSTART_SCRIPT after cloning."
    tput sgr0
fi

echo
tput setaf 2
echo "################################################################"
echo "################### Dale's ChadWM Setup Complete ################"
echo "################################################################"
tput sgr0
echo

echo "✅ ChadWM source method: $SOURCE_METHOD"
echo "✅ ChadWM built and installed from: $CHADWM_BUILD_DIR"
echo "✅ SDDM session file created: /usr/share/xsessions/dale-chadwm.desktop"
echo "✅ Launch script created: /usr/local/bin/chadwm-start"
if [ -f "$AUTOSTART_SCRIPT" ]; then
    echo "✅ Autostart script found: $AUTOSTART_SCRIPT (Made executable)"
else
    echo "⚠️ Autostart script NOT found: $AUTOSTART_SCRIPT (Manual setup may be needed)"
fi
echo

echo "➡️ Reboot your system."
echo "➡️ At the SDDM login screen, select 'DaleChadWM' from the session menu."
