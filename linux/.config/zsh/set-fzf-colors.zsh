# sources auto-generated colors inside 'matugen.zsh'
# and sets $FZF_DEFAULT_OPTS with those colors

()
{
    local fg_selected="#d7e2ff"
    local bg_selected="#294677"
    local preview_bg="#1a1d25"
    local preview_fg="#afb0b3"
    local preview_border="#080a0d"
    local list_border="#92b8c0"
    local input_border="#92b8c0"
    local pointer="#92b8c0"
    local info="#65676c"
    local hl="#ff5d62"
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
        --prompt='→ ' --height ~50% --reverse --info=inline-right \
        --bind 'ctrl-d:half-page-down' \
        --bind 'ctrl-u:half-page-up' \
        --walker-skip .git,node_modules,target,.npm,.cache,csc205,snap,.zen,.var,.cargo/registry \
        --color=fg+:$fg_selected \
        --color=bg+:$bg_selected \
        --color=fg:white \
        --color=preview-bg:$preview_bg \
        --color=preview-fg:$preview_fg \
        --color=preview-border:$preview_border \
        --color=list-border:$list_border \
        --color=input-border:$input_border \
        --color=input-label:$input_border \
        --color=hl:$hl:bold \
        --color=hl+:$hl:bold \
        --color=pointer:$pointer \
        --color=info:$info \
        --color=gutter:$preview_bg" \
}
