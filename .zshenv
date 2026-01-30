# Startup sequence:
# 1) .zenv <-
# 2) .zprofile
# 3) .zshrc
# 4) .zlogin
# 5) .zlogout
#
# zenv is sourced universally in all shells

# echo "entering .zshenv"

export EDITOR="nvim"
# export HISTFILE="$ZDOTDIR/.zhistory"
export HISTFILE="$HOME/.cache/.zhistory"
export HISTSIZE=10000
export MANPAGER='nvim +Man!'
export SAVEHIST="$HISTSIZE"
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
