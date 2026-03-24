# Startup sequence:
# 1) .zenv <-
# 2) .zprofile
# 3) .zshrc
# 4) .zlogin
# 5) .zlogout
#
# zenv is sourced universally in all shells
#

: "${EDITOR:=nvim}"
: "${HISTFILE:=$HOME/.cache/.zhistory}"
: "${HISTSIZE:=1000}"
: "${MANPAGER:=nvim +Man!}"
: "${RIPGREP_CONFIG_PATH:=$HOME/.ripgreprc}"
: "${SAVEHIST:=$HISTSIZE}"
: "${VISUAL:=nvim}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${ZDOTDIR:=$XDG_CONFIG_HOME/zsh}"


source "$ZDOTDIR/set-fzf-colors.zsh"
