#!/bin/bash
#set -e

DRY_RUN=false  # Set to true for testing only

# Clone and install ChadWM from your repo
func_clone_and_build_chadwm() {
    local target_dir="$HOME/.config/chadwm-git"

    echo "🌐 Cloning ChadWM..."
    [[ "$DRY_RUN" = false ]] && {
        rm -rf "$target_dir"
        git clone --depth=1 git@github.com:thorrrr/dale-chadwn.git "$target_dir" || {
            echo "❌ Failed to clone ChadWM repo"
            exit 1
        }

        if [[ -x "$target_dir/scripts/install-chadwm.sh" ]]; then
            chmod +x "$target_dir/scripts/install-chadwm.sh"
            "$target_dir/scripts/install-chadwm.sh"
        else
            echo "⚠️ No install-chadwm.sh found inside $target_dir/scripts/"
        fi
    }
}

# Create autostart script if missing
func_create_autostart_script() {
    local script="$HOME/.config/chadwm/autostart.sh"

    if [[ ! -f "$script" ]]; then
        mkdir -p "$(dirname "$script")"
        cat <<EOF > "$script"
#!/bin/bash
xsetroot -cursor_name left_ptr &
feh --bg-scale ~/Pictures/wallpaper/default.jpg &
picom --experimental-backends &
sxhkd &
exec chadwm
EOF
        chmod +x "$script"
        echo "✅ Created autostart script: $script"
    else
        echo "✔ Autostart script already exists."
    fi
}

# Create xsession .desktop file for SDDM
func_create_xsession_entry() {
    local session_file="/usr/share/xsessions/chadwm.desktop"
    local launcher="/usr/local/bin/chadwm-start"

    if [[ "$DRY_RUN" = false ]]; then
        sudo tee "$session_file" > /dev/null <<EOF
[Desktop Entry]
Name=ChadWM
Comment=ChadWM Session
Exec=$launcher
TryExec=$launcher
Type=Application
X-LightDM-DesktopName=ChadWM
DesktopNames=ChadWM
EOF
        sudo chmod 644 "$session_file"
        echo "✅ SDDM session file created at $session_file"
    fi
}

# Create executable start script for SDDM
func_create_session_launcher() {
    local launcher="/usr/local/bin/chadwm-start"

    if [[ "$DRY_RUN" = false ]]; then
        sudo tee "$launcher" > /dev/null <<EOF
#!/bin/bash
exec \$HOME/.config/chadwm/autostart.sh
EOF
        sudo chmod +x "$launcher"
        echo "✅ Launcher script created: $launcher"
    fi
}

# Install required apps
func_install_apps() {
    local pkgs=(
        alacritty sxhkd feh picom dmenu rofi-lbonn-wayland
        thunar thunar-volman thunar-archive-plugin
        gvfs lxappearance xfce4-notifyd xfce4-power-manager
        xfce4-screenshooter ttf-hack ttf-jetbrains-mono-nerd
        ttf-meslo-nerd-font-powerlevel10k xorg-xsetroot
        volumeicon polkit-gnome
    )

    echo "📦 Installing ChadWM-related apps..."
    for pkg in "${pkgs[@]}"; do
        sudo pacman -S --noconfirm --needed "$pkg"
    done
}

# --- Main Execution ---
echo
tput setaf 2
echo "#######################################"
echo "### Running ChadWM Full Setup Script"
echo "#######################################"
tput sgr0
echo

func_install_apps
func_clone_and_build_chadwm
func_create_autostart_script
func_create_session_launcher
func_create_xsession_entry

echo
tput setaf 6
echo "✅ ChadWM fully installed and registered with SDDM."
echo "➡️  Reboot and choose 'ChadWM' from the SDDM session dropdown."
tput sgr0
