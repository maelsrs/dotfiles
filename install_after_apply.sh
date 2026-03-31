#!/bin/bash
set -e

# ─────────────────────────────────────────────
#  dotfiles bootstrap
# ─────────────────────────────────────────────

WALLPAPER_DIR="$HOME/Pictures/bgs"
WALLPAPERS=(
    "https://raw.githubusercontent.com/maelsrs/dotfiles/main/wallpapers/bocchi-4.png"
    "https://raw.githubusercontent.com/maelsrs/dotfiles/main/wallpapers/kita-1.png"
    "https://raw.githubusercontent.com/maelsrs/dotfiles/main/wallpapers/sitting-1.png"
    "https://raw.githubusercontent.com/maelsrs/dotfiles/main/wallpapers/bocchi-the-rock-wind-song.3840x2160.mp4"
)

PACMAN_PKGS=(
    hyprland hyprpicker xdg-desktop-portal-hyprland quickshell
    waybar rofi swaync kitty thunar tumbler ranger
    brightnessctl cliphist grim slurp pavucontrol wl-clipboard awww
    networkmanager network-manager-applet bluez-utils
    btop fzf eza git jq neovim zsh fastfetch swayidle
    ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd cantarell-fonts
    bibata-cursor-theme-bin
)

AUR_PKGS=(
    catppuccin-gtk-theme-mocha python-pywal16-git
    spicetify-cli spicetify-marketplace-bin spotify sptlrx-bin
    vesktop mpvpaper
)

ZSH_PLUGINS=(
    "https://github.com/romkatv/powerlevel10k.git    themes/powerlevel10k  --depth=1"
    "https://github.com/Aloxaf/fzf-tab.git           plugins/fzf-tab"
    "https://github.com/zsh-users/zsh-autosuggestions plugins/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting plugins/zsh-syntax-highlighting"
)


# ─────────────────────────────────────────────
#  helpers
# ─────────────────────────────────────────────

c_reset="\033[0m"
c_bold="\033[1m"
c_pink="\033[38;5;204m"
c_green="\033[38;5;114m"
c_dim="\033[2m"

header()  { echo -e "\n${c_pink}${c_bold}:: $1${c_reset}"; }
ok()      { echo -e "  ${c_green}✓${c_reset} $1"; }
skip()    { echo -e "  ${c_dim}→ $1${c_reset}"; }

ask() {
    echo -en "  ${c_bold}$1 [y/N]${c_reset} "
    read -r ans
    [[ "$ans" =~ ^[yYoO]$ ]]
}


# ─────────────────────────────────────────────
#  paru
# ─────────────────────────────────────────────

header "AUR helper"

if command -v paru &>/dev/null; then
    ok "paru already installed"
else
    sudo pacman -S --needed --noconfirm base-devel git
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (cd "$tmpdir/paru" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    ok "paru installed"
fi


# ─────────────────────────────────────────────
#  packages
# ─────────────────────────────────────────────

header "Packages (pacman)"
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
ok "done"

header "Packages (AUR)"
paru -S --needed --noconfirm "${AUR_PKGS[@]}"
ok "done"


# ─────────────────────────────────────────────
#  oh-my-zsh
# ─────────────────────────────────────────────

header "Oh-My-Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "installed"
else
    skip "already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for entry in "${ZSH_PLUGINS[@]}"; do
    read -r url dest flags <<< "$entry"
    target="$ZSH_CUSTOM/$dest"
    name=$(basename "$dest")
    if [ ! -d "$target" ]; then
        git clone $flags "$url" "$target"
        ok "$name"
    else
        skip "$name already installed"
    fi
done


# ─────────────────────────────────────────────
#  wallpapers
# ─────────────────────────────────────────────

header "Wallpapers"

mkdir -p "$WALLPAPER_DIR"

for url in "${WALLPAPERS[@]}"; do
    filename=$(basename "$url")
    if [ ! -f "$WALLPAPER_DIR/$filename" ]; then
        curl -sL "$url" -o "$WALLPAPER_DIR/$filename"
        ok "$filename"
    else
        skip "$filename already exists"
    fi
done


# ─────────────────────────────────────────────
#  gtk
# ─────────────────────────────────────────────

header "GTK theme"

gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-pink-standard+default'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaCove Nerd Font Mono 9'

GTK4_SRC="/usr/share/themes/catppuccin-mocha-pink-standard+default/gtk-4.0"
GTK4_DST="$HOME/.config/gtk-4.0"
if [ -d "$GTK4_SRC" ]; then
    mkdir -p "$GTK4_DST"
    cp "$GTK4_SRC/gtk.css" "$GTK4_DST/gtk.css"
    cp "$GTK4_SRC/gtk-dark.css" "$GTK4_DST/gtk-dark.css" 2>/dev/null
    cp -r "$GTK4_SRC/assets" "$GTK4_DST/assets" 2>/dev/null
fi

ok "catppuccin-mocha-pink applied"


# ─────────────────────────────────────────────
#  defaults
# ─────────────────────────────────────────────

header "Defaults"

xdg-mime default thunar.desktop inode/directory
xfconf-query -c thunar -p /misc-single-click -n -t bool -s true 2>/dev/null || true
ok "thunar as file manager"

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    ok "default shell → zsh"
else
    skip "zsh already default"
fi


# ─────────────────────────────────────────────
#  pywal
# ─────────────────────────────────────────────

header "Pywal"

if [ -f "$WALLPAPER_DIR/bocchi-4.png" ]; then
    wal -i "$WALLPAPER_DIR/bocchi-4.png"
    ok "colors generated"
else
    skip "no wallpaper found, run wal manually"
fi


# ─────────────────────────────────────────────
#  lockscreen (quickshell / qylock)
# ─────────────────────────────────────────────

header "Lockscreen (qylock)"

QYLOCK_DIR="$HOME/.local/share/quickshell-lockscreen"

if [ -d "$QYLOCK_DIR" ]; then
    skip "already installed"
elif ask "Install qylock lockscreen?"; then
    git clone https://github.com/Darkkal44/qylock.git "$QYLOCK_DIR"
    chmod +x "$QYLOCK_DIR/lock.sh"
    ok "installed"
else
    skip "skipped"
fi


# ─────────────────────────────────────────────
#  sddm
# ─────────────────────────────────────────────

header "SDDM (terraria theme)"

if [ -d "/usr/share/sddm/themes/terraria" ]; then
    skip "theme already installed"
elif ask "Install SDDM terraria theme? (needs sudo)"; then
    tmpdir=$(mktemp -d)
    git clone https://github.com/Darkkal44/terraria-sddm-theme.git "$tmpdir/terraria"
    sudo cp -r "$tmpdir/terraria" /usr/share/sddm/themes/terraria
    rm -rf "$tmpdir"

    sudo mkdir -p /etc/sddm.conf.d
    echo -e "[Theme]\nCurrent=terraria" | sudo tee /etc/sddm.conf.d/theme.conf > /dev/null
    echo -e "[Users]\nMinimumUid=1000\nMaximumUid=60000" | sudo tee /etc/sddm.conf.d/uid.conf > /dev/null
    ok "installed and configured"
else
    skip "skipped"
fi


# ─────────────────────────────────────────────
#  grub
# ─────────────────────────────────────────────

header "GRUB (joker theme)"

if [ -d "/boot/grub/themes/joker" ]; then
    skip "theme already installed"
elif ask "Install GRUB joker theme? (needs sudo)"; then
    tmpdir=$(mktemp -d)
    git clone https://github.com/jacksaur/Gorgeous-GRUB.git "$tmpdir/grub"
    sudo mkdir -p /boot/grub/themes
    sudo cp -r "$tmpdir/grub/joker" /boot/grub/themes/joker
    rm -rf "$tmpdir"

    sudo sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/joker/theme.txt"|' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ok "installed and applied"
else
    skip "skipped"
fi


# ─────────────────────────────────────────────

echo -e "\n${c_green}${c_bold}all done${c_reset}\n"
