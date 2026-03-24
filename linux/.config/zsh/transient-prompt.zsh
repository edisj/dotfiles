eval "$(starship init zsh)" || exit 1

# see below for potential alternative
# https://github.com/olets/zsh-transient-prompt/blob/main/transient-prompt.zsh-theme
# https://github.com/starship/starship/discussions/5950
# https://github.com/starship/starship/issues/888#issuecomment-3041226060

# https://github.com/starship/starship/issues/888
_set-long-prompt()
{
    export STARSHIP_CONFIG=~/.config/starship.toml
    # PROMPT="$(starship prompt)"
    # PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
    PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
}
precmd_functions+=(_set-long-prompt)

_set-short-prompt()
{
    if [[ $PROMPT != '%# ' ]]; then
        export STARSHIP_CONFIG=~/.config/starship-transient.toml
        # PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
        PROMPT='$(starship prompt --status="$STARSHIP_CMD_STATUS")'
        # zle .reset-prompt
        zle .reset-prompt 2>/dev/null # hide the errors on ctrl+c
    fi
}

zle-line-finish()
{
    _set-short-prompt
}
zle -N zle-line-finish

trap '_set-short-prompt; return 130' INT
