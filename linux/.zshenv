# Startup sequence:
# 1) .zshenv <-
# 2) .zprofile
# 3) .zshrc
# 4) .zlogin
# 5) .zlogout
#
# zshenv is sourced universally in all shells
#

export EDITOR="${EDITOR:-nvim}"
export HISTFILE="${HISTFILE:-$HOME/.cache/.zhistory}"
export HISTSIZE=1000
export MANPAGER="${MANPAGER:-nvim +Man!}"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export SAVEHIST="$HISTSIZE"
export VISUAL="${VISUAL:-nvim}"
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export TERMINAL="kitty"


source "$ZDOTDIR/set-fzf-colors.zsh"
