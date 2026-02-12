# Startup sequence:
# 1) .zenv <-
# 2) .zprofile
# 3) .zshrc
# 4) .zlogin
# 5) .zlogout
#
# zenv is sourced universally in all shells

export EDITOR="nvim"
# export HISTFILE="$ZDOTDIR/.zhistory"
export HISTFILE="$HOME/.cache/.zhistory"
export HISTSIZE=1000
export MANPAGER='nvim +Man!'
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export SAVEHIST="$HISTSIZE"
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
