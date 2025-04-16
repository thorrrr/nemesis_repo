#!/bin/bash
##################################################################################################################
# Author     : Dale Holden
# Purpose    : Installs ChadWM properly with session setup and build process
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
        # Attempt to install the package using sudo
        sudo pacman -S --noconfirm --needed $1 || {
            tput setaf 1 # Red color for error
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "!!! Error installing package $1. Please check pacman output/logs."
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            tput sgr0
            exit 1 # Exit if installation fails
        }
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
    base-devel # Needed for make/gcc
    dash
    dmenu
    feh
    flameshot
    gcc # Needed for make
    gvfs
    kitty
    lxappearance
    make # Needed to build chadwm
    nitrogen
    p7zip
    pavucontrol
    picom
    polkit-gnome # For authentication popups
    rofi
    sddm # Display manager
    sxhkd # Hotkey daemon
    thunar # File manager
    thunar-archive-plugin
    thunar-volman
    ttf-hack
    ttf-jetbrains-mono-nerd # Common Nerd Font for icons
    unrar
    unzip
    volumeicon
    xfce4-notifyd # Notification daemon
    xfce4-power-manager
    xorg # Base Xorg packages
    xorg-xinit
    xorg-xrandr # For display management
    xorg-xsetroot # For setting root window properties
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
# >>> WARNING: Requires passwordless sudo configuration for 'systemctl enable sddm.service' <<<
echo "Enabling SDDM service..."
sudo --nopasswd systemctl enable sddm.service || {
    tput setaf 1
    echo "!!! Error enabling SDDM. Check sudo permissions or remove '--nopasswd'."
    tput sgr0
    # Decide if you want to exit here or just warn: exit 1
}


# Install yay if not installed
if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR Helper)..."
    # Ensure git is installed (should be part of base-devel)
    if ! command -v git &>/dev/null; then func_install git; fi

    if [ -d /tmp/yay-git ]; then
        echo "Removing existing /tmp/yay-git directory..."
        rm -rf /tmp/yay-git
    fi

    git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git || { echo "Error cloning yay repo"; exit 1; }
    cd /tmp/yay-git || exit 1
    # makepkg requires running as a non-root user who can use sudo
    makepkg -si --noconfirm || { echo "Error building/installing yay with makepkg"; exit 1; }
    cd "$HOME" || exit 1
    echo "yay installed successfully."
else
    tput setaf 2
    echo "yay is already installed."
    tput sgr0
fi

# Clean up the target directory structure first
echo "Cleaning up existing target installation: ~/.config/chadwm"
rm -rf ~/.config/chadwm
mkdir -p ~/.config/chadwm # Ensure the target directory exists

# Determine source for ChadWM config/source files
# Suggestion: Simplify this logic if possible. Relying purely on AUR or one specific git repo might be easier.
CHADWM_SOURCE_PATH=""
SOURCE_METHOD=""

# *** Check for the specific source directory from your screenshot first ***
if [ -d ~/.config/arco-chadwm/chadwm ]; then
    echo "Found source files in ~/.config/arco-chadwm/chadwm/. Using this as source."
    # *** THIS IS THE CORRECTED COPY COMMAND ***
    # Copies the *contents* of the inner 'chadwm' directory
    cp -rT ~/.config/arco-chadwm/chadwm ~/.config/chadwm || { echo "Error copying from ~/.config/arco-chadwm/chadwm"; exit 1; }
    CHADWM_SOURCE_PATH="$HOME/.config/chadwm" # Build directly from target dir
    SOURCE_METHOD="Copied from ~/.config/arco-chadwm/chadwm"
elif [ -d ~/.config/dale-chadwn ]; then
     # Assuming dale-chadwn contains the source files directly
    echo "Found source files in ~/.config/dale-chadwn/. Using this as source."
    cp -rT ~/.config/dale-chadwn ~/.config/chadwm || { echo "Error copying from ~/.config/dale-chadwn"; exit 1; }
    CHADWM_SOURCE_PATH="$HOME/.config/chadwm" # Build directly from target dir
    SOURCE_METHOD="Copied from ~/.config/dale-chadwn"
else
    echo "No local source found (arco-chadwm/chadwm or dale-chadwn). Trying AUR package edu-chadwm-git..."
    # Install the AUR package
    # Ensure yay is available
    if ! command -v yay &>/dev/null; then echo "Error: yay command not found, cannot install from AUR."; exit 1; fi
    yay -S --noconfirm edu-chadwm-git || { echo "Error installing edu-chadwm-git via yay."; exit 1; }

    # Copy the installed files (config + potentially source) to user config directory
    if [ -d /usr/share/edu-chadwm ]; then
        echo "Copying installed files from /usr/share/edu-chadwm/* to ~/.config/chadwm/..."
        cp -rT /usr/share/edu-chadwm ~/.config/chadwm || { echo "Error copying from /usr/share/edu-chadwm"; exit 1; }
        CHADWM_SOURCE_PATH="$HOME/.config/chadwm" # Assume source/Makefile is now here
        SOURCE_METHOD="Installed edu-chadwm-git and copied from /usr/share/edu-chadwm"
    else
        echo "Error: edu-chadwm-git installed but /usr/share/edu-chadwm not found."
        exit 1
    fi
fi

# --- Build ChadWM ---
echo "Attempting to build ChadWM..."
if [ -z "$CHADWM_SOURCE_PATH" ]; then
    echo "Error: Could not determine ChadWM source path."
    exit 1
fi

if [ -f "$CHADWM_SOURCE_PATH/Makefile" ]; then
    cd "$CHADWM_SOURCE_PATH" || exit 1
    echo "Building ChadWM from $CHADWM_SOURCE_PATH..."
    make clean || echo "Warning: 'make clean' failed, continuing install..." # Don't exit on clean failure
    # >>> WARNING: Requires passwordless sudo configuration for 'make install' <<<
    # Note: `make install` often copies files to /usr/local/bin, requiring root.
    sudo --nopasswd make install || {
        tput setaf 1
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!! Error: ChadWM 'sudo make install' failed."
        echo "!!! Check build output above and ensure passwordless sudo is configured for make install,"
        echo "!!! or remove '--nopasswd' from the command above."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        tput sgr0
        exit 1
    }
    echo "ChadWM build and install successful."
else
    echo "Error: Makefile not found in $CHADWM_SOURCE_PATH. Cannot build."
    exit 1
fi


# --- Session Setup ---

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
# >>> WARNING: Requires passwordless sudo configuration for 'cp' to /usr/share/xsessions <<<
sudo --nopasswd cp /tmp/chadwm.desktop /usr/share/xsessions/chadwm.desktop || {
    tput setaf 1
    echo "!!! Error copying chadwm.desktop. Check sudo permissions or remove '--nopasswd'."
    tput sgr0
    # Decide if you want to exit here: exit 1
}
rm /tmp/chadwm.desktop


# Create the chadwm launch script
echo "Creating /usr/local/bin/chadwm-start..."
cat > /tmp/chadwm-start <<EOF
#!/bin/bash
# This script should execute your autostart script, which then execs chadwm
# Ensure the path to autostart.sh is correct
exec $HOME/.config/chadwm/autostart.sh
EOF
# >>> WARNING: Requires passwordless sudo configuration for 'cp' and 'chmod' to /usr/local/bin <<<
sudo --nopasswd cp /tmp/chadwm-start /usr/local/bin/chadwm-start || { echo "Error copying chadwm-start"; exit 1; }
sudo --nopasswd chmod +x /usr/local/bin/chadwm-start || { echo "Error setting execute permission on chadwm-start"; exit 1; }
rm /tmp/chadwm-start

# --- Autostart Script Handling ---
AUTOSTART_SCRIPT="$HOME/.config/chadwm/autostart.sh"

if [ -f "$AUTOSTART_SCRIPT" ]; then
    echo "Making existing autostart.sh executable: $AUTOSTART_SCRIPT"
    chmod +x "$AUTOSTART_SCRIPT"
else
    echo "No autostart.sh found in $HOME/.config/chadwm/. Creating a default one..."
    # Make sure parent directory exists
    mkdir -p "$HOME/.config/chadwm"
    cat > "$AUTOSTART_SCRIPT" <<EOF
#!/bin/bash
# Default autostart script for ChadWM - Customize as needed!

# Set wallpaper (ensure feh is installed and path is correct)
# feh --bg-fill $HOME/.config/chadwm/wallpaper/wall.png &

# Start compositor (ensure picom is installed)
picom --config $HOME/.config/chadwm/picom.conf &

# Start hotkey daemon (ensure sxhkd is installed and path is correct)
sxhkd -c $HOME/.config/chadwm/sxhkdrc &

# Start status bar (adjust path to your bar script)
# $HOME/.config/chadwm/scripts/bar.sh &

# Start notification daemon (ensure xfce4-notifyd or dunst is installed)
/usr/lib/xfce4/notifyd/xfce4-notifyd &

# Start volume icon (ensure volumeicon is installed)
volumeicon &

# Start polkit agent (gnome is common, adjust if using mate, lxsession etc.)
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Start power manager (ensure xfce4-power-manager is installed)
xfce4-power-manager &

# Set keyboard layout if needed
# setxkbmap gb &

# Run other startup applications
# nitrogen --restore &
# flameshot &

# Finally, execute the window manager
# IMPORTANT: This should typically be the LAST line
exec chadwm
EOF
    chmod +x "$AUTOSTART_SCRIPT"
    echo "Created default autostart script at: $AUTOSTART_SCRIPT"
    echo ">>> Please review and customize the default autostart script! <<<"
fi


# Print summary of the installation
echo
tput setaf 2
echo "################################################################"
echo "################### ChadWM Setup Complete #######################"
echo "################################################################"
tput sgr0
echo
echo "✅ ChadWM source method: $SOURCE_METHOD"
echo "✅ ChadWM built and installed from: $CHADWM_SOURCE_PATH"
echo "✅ SDDM session file created: /usr/share/xsessions/chadwm.desktop"
echo "✅ Launch script created: /usr/local/bin/chadwm-start"
echo "✅ Autostart script: $AUTOSTART_SCRIPT (Make sure it's executable and customized)"
echo
echo "➡️ Reboot your system."
echo "➡️ At the SDDM login screen, select 'ChadWM' from the session menu (usually a gear icon)."
echo