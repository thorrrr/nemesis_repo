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
        # Attempt to install the package using sudo (will prompt for password)
        # Using --needed ensures already installed dependencies aren't reinstalled
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

# Core required packages (ensure git is included for cloning)
list=(
    alacritty
    arandr
    autorandr
    base-devel # Needed for make/gcc/git
    dash
    dmenu
    feh
    flameshot
    gcc # Needed for make
    git # Needed for cloning the repo
    gvfs
    kitty
    lxappearance
    make # Needed to build chadwm
    nitrogen
    p7zip # Consider replacing with '7zip' if preferred
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
    xorg # Base Xorg packages (will prompt for group selection)
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

# Enable SDDM service (will prompt for password)
echo "Enabling SDDM service..."
sudo systemctl enable sddm.service || {
    tput setaf 1
    echo "!!! Error enabling SDDM. Check sudo permissions or logs."
    tput sgr0
    # Decide if you want to exit here or just warn: exit 1
}


# --- Get User's ChadWM Source ---
USER_CHADWM_REPO_URL="https://github.com/thorrrr/dale-chadwn.git"
# Target directory where config and source will live
CHADWM_CONFIG_DIR="$HOME/.config/chadwm"

echo "Cleaning up existing target installation: $CHADWM_CONFIG_DIR"
rm -rf "$CHADWM_CONFIG_DIR"

echo "Cloning your ChadWM repository from $USER_CHADWM_REPO_URL..."
# Ensure git is installed (handled in dependency list)
if ! command -v git &>/dev/null; then echo "Error: git command not found."; exit 1; fi

git clone "$USER_CHADWM_REPO_URL" "$CHADWM_CONFIG_DIR" || {
    tput setaf 1
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! Error cloning your ChadWM repository from $USER_CHADWM_REPO_URL"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    tput sgr0
    exit 1
}
echo "Repository cloned successfully to $CHADWM_CONFIG_DIR"
SOURCE_METHOD="Cloned from $USER_CHADWM_REPO_URL" # For summary message

# ===> ADDED THIS DEBUG LINE <===
echo "DEBUG: Listing contents of $CHADWM_CONFIG_DIR"
ls -la "$CHADWM_CONFIG_DIR"
echo "DEBUG: End of listing"
# ===> END OF DEBUG LINE <===


# --- Build ChadWM ---
# Source code is expected inside the 'chadwm' subdirectory of the cloned repo
CHADWM_BUILD_DIR="$CHADWM_CONFIG_DIR/chadwm"

echo "Attempting to build ChadWM from $CHADWM_BUILD_DIR..."

if [ ! -d "$CHADWM_BUILD_DIR" ]; then
    tput setaf 1
    echo "Error: Build directory $CHADWM_BUILD_DIR not found after cloning."
    tput sgr0
    exit 1
fi

if [ -f "$CHADWM_BUILD_DIR/Makefile" ]; then
    cd "$CHADWM_BUILD_DIR" || exit 1 # Change into the build directory
    echo "Building ChadWM in $(pwd)..." # Confirm directory

    # === Build Sequence as per user request ===
    # Build first as the regular user
    make || {
        tput setaf 1
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!! Error: ChadWM 'make' (build) failed."
        echo "!!! Check build output above."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        tput sgr0
        exit 1
    }
    echo "Build step completed successfully."

    # Clean and Install using sudo (will prompt for password)
    # Note: `make clean install` often copies files to /usr/local/bin, requiring root.
    sudo make clean install || {
        tput setaf 1
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!! Error: ChadWM 'sudo make clean install' failed."
        echo "!!! Check install output above."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        tput sgr0
        exit 1
    }
    echo "ChadWM clean and install successful."
    # ==============================

    # Optional: change back to home directory if needed
    # cd "$HOME" || exit 1
else
    tput setaf 1
    echo "Error: Makefile not found in $CHADWM_BUILD_DIR. Cannot build."
    tput sgr0
    exit 1
fi


# --- Session Setup ---

# Create SDDM session entry (will prompt for password)
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
# Copying to system directory requires sudo
sudo cp /tmp/chadwm.desktop /usr/share/xsessions/dale-chadwm.desktop || {
    tput setaf 1
    echo "!!! Error copying dale-chadwm.desktop. Check sudo permissions or logs."
    tput sgr0
    # Decide if you want to exit here: exit 1
}
rm /tmp/chadwm.desktop


# Create the chadwm launch script (will prompt for password for cp and chmod)
echo "Creating /usr/local/bin/chadwm-start..."
# This script needs to execute the correct autostart script from your repo
# Check your repo structure - is autostart.sh at the root or inside 'scripts'?
# Assuming it's at the root ($CHADWM_CONFIG_DIR/autostart.sh) for now:
cat > /tmp/chadwm-start <<EOF
#!/bin/bash
# Executes the autostart script from Dale's ChadWM config
exec $HOME/.config/chadwm/autostart.sh
EOF
# Copying & setting permissions requires sudo
sudo cp /tmp/chadwm-start /usr/local/bin/chadwm-start || { echo "Error copying chadwm-start"; exit 1; }
sudo chmod +x /usr/local/bin/chadwm-start || { echo "Error setting execute permission on chadwm-start"; exit 1; }
rm /tmp/chadwm-start

# --- Autostart Script Handling ---
# Check if autostart.sh exists in the cloned repo and make it executable
# Adjust path if it's not at the root of $CHADWM_CONFIG_DIR
AUTOSTART_SCRIPT="$CHADWM_CONFIG_DIR/autostart.sh"

if [ -f "$AUTOSTART_SCRIPT" ]; then
    echo "Making your autostart.sh executable: $AUTOSTART_SCRIPT"
    chmod +x "$AUTOSTART_SCRIPT"
else
    # If your repo *should* contain autostart.sh, this indicates a problem
    tput setaf 3 # Yellow warning
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! Warning: Autostart script not found at $AUTOSTART_SCRIPT after cloning."
    echo "!!! You may need to create it manually or check your repository structure."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    tput sgr0
    # Optionally create a minimal default here, but it's better if it comes from the repo
fi


# Print summary of the installation
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
echo "➡️ At the SDDM login screen, select 'DaleChadWM' from the session menu (usually a gear icon)."
echo