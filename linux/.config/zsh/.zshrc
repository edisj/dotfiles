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

# To have paths colored instead of underlined
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

bindkey -v && export KEYTIMEOUT=1
bindkey '\ea' vi-cmd-mode
bindkey -M vicmd 'q' vi-backward-word
bindkey -M vicmd 'Q' vi-backward-blank-word
bindkey -M vicmd 'H' vi-beginning-of-line
bindkey -M vicmd 'L' vi-end-of-line
bindkey -M viins '^B' vi-backward-word
bindkey -M viins '^E' vi-forward-word
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

stty -ixon
bindkey '^S' history-incremental-search-forward
bindkey '^R' history-incremental-search-backward

# use an anonymous function here to prevent polluting env namespace when sourcing this
() {

    # IMPORTANT: need to load complist BEFORE autoloading compinit
    zmodload zsh/complist
    ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    mkdir -p "$ZSH_CACHE_DIR"
    autoload -Uz compinit && compinit -d "$ZSH_CACHE_DIR/.zcompdump-${ZSH_VERSION}"

    bindkey              '^I'         menu-complete
    bindkey "$terminfo[kcbt]" reverse-menu-complete

    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect '^Y' accept-line
    bindkey -M menuselect '^W' undo

    # zstyle ':completion:*' menu yes select
    zstyle ':completion:*' menu select
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

zstyle ':completion:*' list-separator '  '
zstyle ':completion:*' list-colors '=(#b)(*)  (*)=33=0'

    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd v edit-command-line

    local prefix
    [[ "$(uname)" == "Darwin" ]] && prefix="/opt/homebrew/share/" || prefix="/usr/share/"
    local plugs=(
        "zsh-autosuggestions/zsh-autosuggestions.zsh"
        "zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    )
    for plug in "${plugs[@]}"; do
        [[ -f "$prefix$plug" ]] && source "$prefix$plug"
    done
}

_fzf-nvim()
{
    BUFFER="fzf-nvim $BUFFER"
    zle accept-line || echo "ERROR?"
}
zle -N _fzf-nvim
bindkey '^O' _fzf-nvim
bindkey -s "^P" "fzf-dnf\n"
bindkey -s "^E" "fzf-edis\n"

source "$ZDOTDIR/aliases.zsh"
if command -v uv &> /dev/null; then eval "$(uv generate-shell-completion zsh)"; fi
if command -v starship &> /dev/null; then source "$ZDOTDIR/transient-prompt.zsh"; fi
