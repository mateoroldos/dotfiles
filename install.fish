#!/usr/bin/env fish

set DOTFILES (dirname (realpath (status filename)))

echo ""
echo "==> dotfiles installer"
echo ""

# 1. AUR helper
if not command -q yay
    echo "==> Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    cd /tmp/yay-install && makepkg -si --noconfirm
    rm -rf /tmp/yay-install
else
    echo "==> yay already installed, skipping"
end

# 2. pacman packages
echo "==> Installing pacman packages..."
set pkgs (grep -v '^\s*#' $DOTFILES/packages/pacman.txt | grep -v '^\s*$')
sudo pacman -S --needed --noconfirm $pkgs

# 3. AUR packages
echo "==> Installing AUR packages..."
set aur_pkgs (grep -v '^\s*#' $DOTFILES/packages/aur.txt | grep -v '^\s*$')
yay -S --needed --noconfirm $aur_pkgs

# 4. Set keyd
echo "==> Setting up keyd..."
 
sudo mkdir -p /etc/keyd
sudo ln -sf ~/dotfiles/keyd/default.conf /etc/keyd/default.conf
 
sudo systemctl enable --now keyd
sudo keyd reload
 
# 5. Symlink configs via stow
echo "==> Linking configs with stow..."
stow --dir=$DOTFILES/config --target=$HOME/.config .

# 6. Dev tools from mise (node, bun, portless, ...)
echo "==> Installing mise tools..."
mise install

# 7. Portless proxy service
# Owns :443 for *.localhost. Without it the proxy is started ad-hoc by whichever
# repo runs `portless` first, and its version wins for every other project.
echo "==> Installing portless service..."
sudo (mise which portless) service install

echo ""
echo "==> All done! Restart your shell or run: exec fish"
echo ""
