# Startup sequence:
# 1) .zenv
# 2) .zprofile
# 3) .zshrc <-
# 4) .zlogin
# 5) .zlogout
#
# zshrc is sourced only in interative shells
# i.e. when running `zsh` without a file argument

# echo "entering .zshrc"

setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.

# completion using arrow keys (based on history)
bindkey '^[OA' history-search-backward
bindkey '^[OB' history-search-forward

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source "$ZDOTDIR/.zsh_aliases"
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# autoload -U compinit; compinit
bindkey -v
export KEYTIMEOUT=1

typeset -A ZSH_HIGHLIGHT_STYLES
# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

eval "$(uv generate-shell-completion zsh)"
eval "$(starship init zsh)"

# SEE https://github.com/starship/starship/issues/888
set-long-prompt() {
    export STARSHIP_CONFIG=~/.config/starship.toml
    PROMPT="$(starship prompt)"
}
precmd_functions+=(set-long-prompt)

set-short-prompt() {
    if [[ $PROMPT != '%# ' ]]; then
        export STARSHIP_CONFIG=~/.config/starship-transient.toml
        PROMPT="$(starship prompt)"
        zle .reset-prompt 2>/dev/null # hide the errors on ctrl+c
    fi
}

zle-line-finish() {
    set-short-prompt
}
zle -N zle-line-finish

trap 'set-short-prompt; return 130' INT
