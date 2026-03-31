# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## What's included

| Category | Config | Description |
|----------|--------|-------------|
| Shell | `.zshrc`, `.bashrc`, `.p10k.zsh` | Zsh with Oh-My-Zsh, Powerlevel10k, fzf, eza aliases |
| WM | `hypr/` | Hyprland: keybindings, animations, window rules, themes |
| Bar | `waybar/` | Waybar: workspaces, network stats, battery, clock, tray |
| Launcher | `rofi/` | Rofi: drun, clipboard (cliphist), wallpaper selector, 9 styles |
| Terminal | `kitty/` | Kitty with Catppuccin Mocha theme |
| Editor | `nvim/` | Neovim with NvChad, LSP, conform, lazy.nvim |
| Notifs | `swaync/` | SwayNC with Catppuccin theme, power/lock/DND buttons |
| Monitor | `btop/` | Btop system monitor |
| Audio | `cava/`, `catnip/` | Audio visualizers |
| Files | `ranger/` | Ranger file manager |
| Fetch | `fastfetch/` | System info on terminal launch |
| Spotify | `spicetify/` | Spotify customization |
| Wallpaper | `hypr/UserScripts/` | Wallpaper selector (rofi) with awww + mpvpaper support |
| GTK | `gtk-4.0/` | Catppuccin Mocha Pink GTK4 theme |
| Scripts | `hyprdots/scripts/` | globalcontrol, cliphist, rofilaunch |

## Manual setup (not in dotfiles)

These settings can't be tracked by chezmoi and must be applied manually after install.

### 1. GTK Theme

```bash
paru -S catppuccin-gtk-theme-mocha
gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-pink-standard+default'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaCove Nerd Font Mono 9'
```

Also update `/home/.config/xsettingsd/xsettingsd.conf`:
```
Net/ThemeName "catppuccin-mocha-pink-standard+default"
Net/IconThemeName "Adwaita"
```

### 2. Default applications

```bash
xdg-mime default thunar.desktop inode/directory
```

### 3. Thunar single-click

```bash
xfconf-query -c thunar -p /misc-single-click -n -t bool -s true
```

### 4. Packages

#### Official repos

```bash
sudo pacman -S hyprland hyprpicker xdg-desktop-portal-hyprland quickshell \
  waybar rofi swaync kitty thunar tumbler ranger \
  brightnessctl cliphist grim slurp pavucontrol wl-clipboard awww \
  networkmanager network-manager-applet bluez-utils \
  btop fzf eza git jq neovim zsh fastfetch \
  ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd cantarell-fonts \
  bibata-cursor-theme-bin
```

#### AUR

```bash
paru -S catppuccin-gtk-theme-mocha python-pywal16-git \
  spicetify-cli spicetify-marketplace-bin spotify sptlrx-bin \
  vesktop mpvpaper
```

### 5. Oh-My-Zsh + plugins

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 6. Pywal

Generate initial color scheme:
```bash
wal -i ~/Pictures/bgs/bocchi-4.png
```

### 7. Keyboard (French AZERTY)

Configured in `hyprland.conf`:
- Layout: `fr`
- `kb_options = numpad:microsoft` (numpad always outputs numbers, no numlock needed)

### 8. Lockscreen (Quickshell)

Lockscreen uses [qylock](https://github.com/Darkkal44/qylock) with the terraria theme:
- Location: `~/.local/share/quickshell-lockscreen/`
- Theme: terraria (`QS_THEME=terraria`)
- Wallpaper: `~/Pictures/bgs/bocchi-4.png`
- Colors: pywal (`~/.cache/wal/colors-hyprland.conf`)

Make sure quickshell is installed and pywal has been run before first lock.

### 9. SDDM (system files, not in chezmoi)

Theme: `terraria`
- Installed in `/usr/share/sddm/themes/terraria/`
- Config: `/etc/sddm.conf`

```ini
[Theme]
Current=terraria

[Users]
MinimumUid=1000
MaximumUid=60000
```

### 10. GRUB (system files, not in chezmoi)

Theme: `joker` from [Gorgeous-GRUB](https://github.com/jacksaur/Gorgeous-GRUB)
- Installed in `/boot/grub/themes/joker/`
- Enable in `/etc/default/grub`:

```bash
GRUB_THEME="/boot/grub/themes/joker/theme.txt"
```

Then run `sudo grub-mkconfig -o /boot/grub/grub.cfg` to apply.
