#!/bin/bash
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

##################################################################################################################
# Colors for better output
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
        echo "################## The package "$1" is already installed"
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
        sudo pacman -S --noconfirm --needed $1
    fi
}

echo
tput setaf 3
echo "################################################################"
echo "################### Installing ChadWM Setup #####################"
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

# Core required packages
list=(
    alacritty
    arandr
    autorandr
    base-devel
    dash
    dmenu
    feh
    flameshot
    gcc
    gvfs
    kitty
    lxappearance
    make
    nitrogen
    p7zip
    pavucontrol
    picom
    polkit-gnome
    rofi
    sddm
    sxhkd
    thunar
    thunar-archive-plugin
    thunar-volman
    ttf-hack
    ttf-jetbrains-mono-nerd
    unrar
    unzip
    volumeicon
    xfce4-notifyd
    xfce4-power-manager
    xorg
    xorg-xinit
    xorg-xrandr
    xorg-xsetroot
    zip
)

count=0
for name in "${list[@]}" ; do
    count=$[count+1]
    tput setaf 3
    echo "Installing package nr. "$count " " $name
    tput sgr0
    func_install $name
done

# Enable SDDM without asking for password
echo "Enabling SDDM service..."
sudo --nopasswd systemctl enable sddm.service

# Install yay if not installed
if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
    cd /tmp/yay-git || exit 1
    makepkg -si --noconfirm
    cd "$HOME" || exit 1
fi

# Clean up the directory structure first
echo "Cleaning up existing chadwm installation..."
rm -rf ~/.config/chadwm

# Check if arco-chadwm directory exists locally
if [ -d ~/.config/arco-chadwm ]; then
    echo "Using existing arco-chadwm as base..."
    cp -r ~/.config/arco-chadwm ~/.config/chadwm
    echo "Copied arco-chadwm to chadwm"
else
    # Use the existing dale-chadwn folder if it's already cloned
    if [ -d ~/.config/dale-chadwn ]; then
        echo "Using existing dale-chadwn folder..."
        cp -r ~/.config/dale-chadwn ~/.config/chadwm
    else
        # Clone the edu-chadwm-git package files instead from AUR
        # This avoids GitHub authentication issues
        echo "Setting up ChadWM from edu-chadwm-git package..."
        yay -S --noconfirm edu-chadwm-git
        
        # Copy the installed files to your config directory
        echo "Copying installed files to ~/.config/chadwm..."
        mkdir -p ~/.config/chadwm
        cp -r /usr/share/edu-chadwm/* ~/.config/chadwm/
    fi
fi

# Try to locate the build directory
if [ -d ~/.config/chadwm/chadwm ]; then
    cd ~/.config/chadwm/chadwm || exit 1
    echo "Building ChadWM from ~/.config/chadwm/chadwm..."
    make clean
    sudo --nopasswd make clean install
elif [ -f ~/.config/chadwm/Makefile ]; then
    cd ~/.config/chadwm || exit 1
    echo "Building ChadWM from ~/.config/chadwm..."
    make clean
    sudo --nopasswd make clean install
else
    echo "Finding build directory..."
    BUILD_DIR=$(find ~/.config/chadwm -name "Makefile" -type f | head -n 1)
    if [ ! -z "$BUILD_DIR" ]; then
        BUILD_DIR=$(dirname "$BUILD_DIR")
        echo "Found build directory at: $BUILD_DIR"
        cd "$BUILD_DIR" || exit 1
        make clean
        sudo --nopasswd make clean install
    else
        echo "Error: Cannot find chadwm build directory with Makefile."
        echo "Will try to use the system-installed chadwm binary instead."
    fi
fi

# Create SDDM session entry
echo "Creating ChadWM desktop session entry..."
cat > /tmp/chadwm.desktop <<EOF
[Desktop Entry]
Name=ChadWM
Comment=ChadWM window manager session
Exec=/usr/local/bin/chadwm-start
TryExec=/usr/local/bin/chadwm-start
Type=Application
DesktopNames=ChadWM
EOF
sudo --nopasswd cp /tmp/chadwm.desktop /usr/share/xsessions/chadwm.desktop

# Create the chadwm launch script
echo "Creating /usr/local/bin/chadwm-start..."
cat > /tmp/chadwm-start <<EOF
#!/bin/bash
exec ~/.config/chadwm/autostart.sh
EOF
sudo --nopasswd cp /tmp/chadwm-start /usr/local/bin/chadwm-start
sudo --nopasswd chmod +x /usr/local/bin/chadwm-start

# Make sure autostart is executable
if [ -f ~/.config/chadwm/autostart.sh ]; then
    chmod +x ~/.config/chadwm/autostart.sh
    echo "Made autostart.sh executable."
else
    echo "Looking for autostart script..."
    AUTOSTART=$(find ~/.config/chadwm -name "autostart.sh" | head -n 1)
    if [ ! -z "$AUTOSTART" ]; then
        echo "Found autostart script at: $AUTOSTART"
        chmod +x "$AUTOSTART"
        # Create symlink if it's in a subdirectory
        if [ "$AUTOSTART" != "~/.config/chadwm/autostart.sh" ]; then
            ln -sf "$AUTOSTART" ~/.config/chadwm/autostart.sh
            echo "Created symlink to autostart.sh"
        fi
    else
        echo "No autostart.sh found. Creating minimal autostart script..."
        mkdir -p ~/.config/chadwm
        cat > ~/.config/chadwm/autostart.sh <<EOF
#!/bin/bash
# Default autostart script for ChadWM

# Set wallpaper
feh --bg-fill ~/.config/chadwm/wallpaper/wall.png &

# Start compositor
picom &

# Start status bar
~/.config/chadwm/scripts/bar.sh &

# Start notification daemon
/usr/lib/xfce4/notifyd/xfce4-notifyd &

# Start volume icon
volumeicon &

# Start polkit agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Start xfce4-power-manager
xfce4-power-manager &

# Start window manager
exec chadwm
EOF
        chmod +x ~/.config/chadwm/autostart.sh
    fi
fi

# Print summary of the installation
echo
tput setaf 2
echo "################################################################"
echo "################### ChadWM Setup Complete #######################"
echo "################################################################"
tput sgr0
echo
echo "✅ Installed to: ~/.config/chadwm"
echo "✅ Reboot and select ChadWM from the SDDM login menu."
echo
echo "Directory Structure:"
find ~/.config/chadwm -maxdepth 2 -type d | sort
echo
echo "Build Files:"
find ~/.config/chadwm -name "Makefile" | sort