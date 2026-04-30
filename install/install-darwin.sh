#!/usr/bin/env zsh

source "$HOME/.local/scripts/lib/logging.sh"

tap() {
	brew tap "$1" && success "tapped $1" || (error "could not tap $1" && exit 1)
}

info "tapping casks..."
tap FelixKratz/formulae
echo ""

packages=(
    bat
    borders
    btop
    eza
    fd
    fzf
    gh
    ghostty
    git
    jq
    kitty
    lf
    python
    qt
    ripgrep
    rust
    sketchybar
    starship
    stow
    tldr
    tree-sitter-cli
    uv
    zen
    zsh-autosuggestions
    zsh-syntax-highlighting
)

info "installing brew packages..."
brew install "${packages[@]}"
