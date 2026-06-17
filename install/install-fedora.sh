#!/usr/bin/env bash

source "$HOME/.local/scripts/lib/logging.sh"

copr_enable() {
    local repo="$1"
    sudo dnf -y copr enable $repo &>/dev/null && LOG_DONE "enabled copr $1" \
        || (LOG_ERROR "$repo is invalid" && exit 1)
}

LOG_INFO "enabling coprs..."
# copr_enable solopasha/hyprland
copr_enable sdegler/hyprland
# copr_enable solopasha/hyprland
copr_enable alternateved/eza
copr_enable agriffis/neovim-nightly
copr_enable pennbauman/ports
copr_enable atim/starship
copr_enable sneexy/zen-browser
copr_enable errornointernet/walker
copr_enable bijumon/neovide-release
copr_enable scottames/ghostty
copr_enable foopsss/shell-color-scripts
echo ""

packages=(
    bat
    btop
    cargo
    dbus-devel
    elephant
    eza
    fastfetch
    fd-find
    fontawesome-fonts-all
    fzf
    gh
    git
    htop
    hypridle
    hyprland
    hyprlock
    hyprpaper
    java-25-openjdk-devel
    kitty
    libjpeg-turbo-devel
    libpng-devel
    libnotify
    libreoffice
    magick
    mako
    neovim
    pkgconf-pkg-config
    pavucontrol
    pipewire
    pipewire-pulse
    python3-neovim
    ripgrep
    sddm
    shell-color-scripts
    snapd
    starship
    stow
    terminus-fonts-console
    tldr
    # tree-sitter-cli
    uv
    walker
    waybar
    wiremix
    which
    xdg-terminal-exec
    zen-browser
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
)

LOG_INFO "installing dnf packages..."
sudo dnf --quiet install -y "${packages[@]}"

echo ""
LOG_INFO "installing snap packages..."
sudo snap install zotero-snap


readonly cargo_crates=(
    bluetui
    impala
    neovide
)

echo ""
LOG_INFO "installing cargo crates..."
cargo install "${cargo_crates[@]}"
