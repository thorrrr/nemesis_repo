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

# Core required packages - similar to Erik's but including yours
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

# Enable SDDM
echo "Enabling SDDM service..."
sudo systemctl enable sddm.service

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

# Clone your arco-chadwm config instead (which has the correct structure)
echo "Setting up ChadWM from your arco-chadwm repository..."
if [ -d ~/.config/arco-chadwm ]; then
    # If arco-chadwm exists, copy it to chadwm
    cp -r ~/.config/arco-chadwm ~/.config/chadwm
    echo "Using existing arco-chadwm as base for chadwm installation"
else
    # Else, use direct clone with proper structure
    git clone --depth=1 https://github.com/thorrrr/arco-chadwm.git ~/.config/chadwm
    echo "Cloned arco-chadwm repository"
fi

# Make sure we're in the right directory with the source code
if [ -d ~/.config/chadwm/chadwm ]; then
    cd ~/.config/chadwm/chadwm || exit 1
    echo "Building ChadWM from ~/.config/chadwm/chadwm..."
    make clean
    sudo make clean install
elif [ -d ~/.config/chadwm ]; then
    # Try to find the build directory
    if [ -f ~/.config/chadwm/Makefile ]; then
        cd ~/.config/chadwm || exit 1
        echo "Building ChadWM from ~/.config/chadwm..."
        make clean
        sudo make clean install
    else
        echo "Error: Cannot find chadwm build directory with Makefile."
        echo "Current directory structure:"
        find ~/.config/chadwm -type f -name "Makefile" | sort
        exit 1
    fi
else
    echo "Error: ChadWM repository not found or failed to clone."
    exit 1
fi

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

# Create the chadwm launch script
echo "Creating /usr/local/bin/chadwm-start..."
sudo tee /usr/local/bin/chadwm-start >/dev/null <<EOF
#!/bin/bash
exec ~/.config/chadwm/autostart.sh
EOF

sudo chmod +x /usr/local/bin/chadwm-start

# Make sure autostart is executable
if [ -f ~/.config/chadwm/autostart.sh ]; then
    chmod +x ~/.config/chadwm/autostart.sh
    echo "Made autostart.sh executable."
else
    echo "Warning: autostart.sh not found."
    # Try to find the autostart script
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
        echo "No autostart.sh found in chadwm directories. Please create one."
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