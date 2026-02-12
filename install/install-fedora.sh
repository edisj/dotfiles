#!/usr/bin/env bash

error()
{
    local msg="$1"
    echo -e "[\e[1;31mERROR\e[0m] \e[36m$(basename $0)\e[0m: $msg"
    echo "exiting..."
    exit 1
}

success()
{
    local msg="$1"
    echo -e "[\e[1;32mSUCCESS\e[0m] \e[36m$(basename $0)\e[0m: $msg"
}

info()
{
    local msg="$1"
    echo -e "[\e[1;34mINFO\e[0m] \e[36m$(basename $0)\e[0m: $msg"
}

copr_enable()
{
    local repo="$1"

    sudo dnf -y copr enable $repo &>/dev/null && success "enabled copr $1" || error "$repo is invalid"
}

info "enabling coprs..."
copr_enable solopasha/hyprland
copr_enable alternateved/eza
copr_enable agriffis/neovim-nightly
copr_enable pennbauman/ports
copr_enable atim/starship
copr_enable sneexy/zen-browser
copr_enable errornointernet/walker
echo ""

packages=(
    bat
    btop
    cargo
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
    # ImageMagick
    java-latest-openjdk-devel
    kitty
    libjpeg-turbo-devel
    libpng-devel
    libnotify
    libreoffice
    magick
    mako
    neovim
    pavucontrol
    pipewire
    pipewire-pulse
    python3-neovim
    ripgrep
    sddm
    snapd
    starship
    stow
    terminus-fonts-console
    tldr
    tree-sitter-cli
    uv
    walker
    waybar
    wiremix
    which
    wofi
    xdg-terminal-exec
    zen-browser
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
)

info "installing dnf packages..."
sudo dnf --quiet install -y "${packages[@]}"

echo ""
info "installing snap packages..."
sudo snap install zotero-snap

