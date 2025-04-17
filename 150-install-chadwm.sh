#!/bin/bash
##################################################################################################################
# Author  : Dale Holden
# Script  : 150-install-chadwm.sh
# Purpose : Install Dale’s ChadWM spin _exactly_ the way ATT does – but from **your** repo – and
#           register the proper SDDM session + helper wrapper, while keeping XFCE as safe fallback.
##################################################################################################################
set -e

# -------- CONFIG --------------------------------------------------------------------------
REPO_URL="https://github.com/thorrrr/dale-chadwn.git"   # your fork
CFG_DIR="$HOME/.config/arco-chadwm"                     # where ATT places it
LAUNCHER="/usr/bin/exec-chadwm"                         # keep identical to ATT
SESSION_FILE="/usr/share/xsessions/chadwm.desktop"

# Core packages taken from ATT + extra build deps
pkgs=(
  alacritty arandr autorandr base-devel dash dmenu feh flameshot gcc git gvfs lxappearance make
  nitrogen 7zip pavucontrol picom polkit-gnome rofi sxhkd thunar thunar-archive-plugin thunar-volman
  ttf-hack ttf-jetbrains-mono-nerd unrar unzip volumeicon xfce4-notifyd xfce4-power-manager
  xfce4-screenshooter xfce4-settings xfce4-taskmanager xfce4-terminal nano xorg xorg-xinit
  xorg-xrandr xorg-xsetroot zip sddm
)
# -------------------------------------------------------------------------------------------

msg()  { tput setaf 3; echo -e "[INFO]  $*"; tput sgr0; }
err()  { tput setaf 1; echo -e "[ERROR] $*" >&2; tput sgr0; exit 1; }
okay() { tput setaf 2; echo -e "[OK]   $*"; tput sgr0; }

printf "\n\e[33m%-64s\e[0m\n" "################ Installing Dale\'s ChadWM setup ################"

# 1. Packages ------------------------------------------------------------------------------
for p in "${pkgs[@]}"; do
  if ! pacman -Qi "$p" &>/dev/null; then
    msg "Installing $p"
    sudo pacman -S --noconfirm --needed "$p" || err "pacman failed on $p"
  else
    okay "$p already installed"
  fi
done

sudo systemctl enable sddm.service &>/dev/null || err "Could not enable SDDM"

# 2. Clone / update repo -------------------------------------------------------------------
msg "Syncing ChadWM repo → $CFG_DIR"
rm -rf "$CFG_DIR"

git clone --depth 1 "$REPO_URL" "$CFG_DIR" || err "git clone failed"

# 3. Determine build dir (root vs sub‑folder) ----------------------------------------------
if   [[ -f "$CFG_DIR/Makefile"            ]]; then BUILD_DIR="$CFG_DIR"
elif [[ -f "$CFG_DIR/chadwm/Makefile"     ]]; then BUILD_DIR="$CFG_DIR/chadwm"
else err "Makefile not found — repository layout unexpected"
fi
msg "Building from $BUILD_DIR"

pushd "$BUILD_DIR" >/dev/null
make >/dev/null
sudo make clean install >/dev/null
popd >/dev/null

# 4. Create session + wrapper --------------------------------------------------------------
msg "Creating SDDM session entry"
cat <<EOF | sudo tee "$SESSION_FILE" >/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=Chadwm
Comment=Dynamic window manager
Exec=$LAUNCHER
Icon=chadwm
Type=Application
EOF

msg "Writing launcher $LAUNCHER (mirrors ATT startup order)"
cat <<'EOF' | sudo tee "$LAUNCHER" >/dev/null
#!/bin/bash
pgrep -x sxhkd  >/dev/null || sxhkd &
picom &
volumeicon &
xfce4-notifyd &
[ -f "$HOME/Pictures/wallpaper.jpg" ] && feh --bg-scale "$HOME/Pictures/wallpaper.jpg" &
exec chadwm
EOF
sudo chmod +x "$LAUNCHER"

# 5. Success message ----------------------------------------------------------------------
printf "\n\e[32m%-64s\e[0m\n" "################  ChadWM install complete ################"
okay "SDDM session : $SESSION_FILE"
okay "Launch script : $LAUNCHER"
okay "Built from    : $BUILD_DIR"

echo -e "\nReboot and pick \e[1mChadwm\e[0m in SDDM.  XFCE remains as fallback."
