#!/bin/bash
##################################################################################################################
# Author     : Dale Holden
# Purpose    : Installs Dale's ChadWM build the _same_ way the ArcoLinux Tweak Tool does, but using *your* Git repo.
#              • Installs all needed runtime / build packages (skipping ones that are already present)
#              • Clones or updates the repo to ~/.config/arco-chadwm
#              • Finds the first Makefile anywhere inside the repo and builds/installs it
#              • Creates the *exact* ATT launch path:   /usr/bin/exec-chadwm   +   /usr/share/xsessions/chadwm.desktop
#              • Does **not** touch or break XFCE – ChadWM is an *additional* session you can pick in SDDM.
##################################################################################################################
set -euo pipefail

# --- 0. Configuration ------------------------------------------------------------------------
REPO_URL="https://github.com/thorrrr/dale-chadwm.git"   # ← your repo
CONFIG_DIR="$HOME/.config/arco-chadwm"                  # where the repo lives locally
EXEC_WRAPPER="/usr/bin/exec-chadwm"                    # ATT‑compat launch script
DESKTOP_FILE="/usr/share/xsessions/chadwm.desktop"     # ATT‑compat session file

# --- 1. Helper -------------------------------------------------------------------------------
msg()   { tput setaf 6; printf "[INFO]  %s\n"  "$1"; tput sgr0; }
okay()  { tput setaf 2; printf "[OK]    %s\n"  "$1"; tput sgr0; }
err()   { tput setaf 1; printf "[ERROR] %s\n" "$1"; tput sgr0; exit 1; }
install_pkg() {
    if pacman -Qi "$1" &>/dev/null; then okay "$1 already installed"; else
        msg "Installing $1"; sudo pacman -S --noconfirm --needed "$1" || err "could not install $1"; fi }

# --- 2. Packages -----------------------------------------------------------------------------
msg "Installing runtime + build dependencies"
PKGS=(
  alacritty arandr autorandr base-devel dash dmenu feh flameshot gcc git gvfs lxappearance
  make nitrogen p7zip pavucontrol picom polkit-gnome rofi sxhkd thunar thunar-archive-plugin
  thunar-volman ttf-hack ttf-jetbrains-mono-nerd unrar unzip volumeicon xfce4-notifyd
  xfce4-power-manager xfce4-screenshooter xfce4-settings xfce4-taskmanager xfce4-terminal nano
  xorg xorg-xinit xorg-xrandr xorg-xsetroot zip sddm
)
for p in "${PKGS[@]}"; do install_pkg "$p"; done

sudo systemctl enable --quiet sddm.service || true

# --- 3. Clone / update repo ------------------------------------------------------------------
if [[ -d "$CONFIG_DIR/.git" ]]; then
    msg "Updating existing repo in $CONFIG_DIR" && git -C "$CONFIG_DIR" pull --ff-only
else
    msg "Cloning repo → $CONFIG_DIR" && rm -rf "$CONFIG_DIR" && git clone --depth 1 "$REPO_URL" "$CONFIG_DIR"
fi

# --- 4. Locate Makefile & build --------------------------------------------------------------
msg "Searching for Makefile in repo"
MAKEFILE_PATH=$(find "$CONFIG_DIR" -maxdepth 3 -type f -name Makefile | head -n1 || true)
[[ -z "$MAKEFILE_PATH" ]] && err "Makefile not found – check repo layout"
BUILD_DIR=$(dirname "$MAKEFILE_PATH")
msg "Building ChadWM in $BUILD_DIR"
make  -C "$BUILD_DIR"
sudo make -C "$BUILD_DIR" clean install

# --- 5. Create ATT‑style wrapper -------------------------------------------------------------
msg "Creating $EXEC_WRAPPER"
cat | sudo tee "$EXEC_WRAPPER" >/dev/null <<'EOF'
#!/bin/bash
pgrep -x sxhkd >/dev/null || sxhkd &
picom &
volumeicon &
xfce4-notifyd &
[ -f "$HOME/Pictures/wallpaper.jpg" ] && feh --bg-scale "$HOME/Pictures/wallpaper.jpg" &
exec chadwm
EOF
sudo chmod +x "$EXEC_WRAPPER"

msg "Creating $DESKTOP_FILE"
cat | sudo tee "$DESKTOP_FILE" >/dev/null <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Chadwm
Comment=Dynamic window manager (Dale build)
Exec=$EXEC_WRAPPER
Icon=chadwm
Type=Application
EOF

# --- 6. Done ---------------------------------------------------------------------------------
okay "ChadWM built and installed from $BUILD_DIR"
okay "Session file : $DESKTOP_FILE"
okay "Launch script: $EXEC_WRAPPER"
printf "\n➡️  Reboot and choose *ChadWM* in SDDM. XFCE remains available as usual.\n"
