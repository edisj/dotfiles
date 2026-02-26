# sources auto-generated colors inside 'matugen.zsh'
# and sets $FZF_DEFAULT_OPTS with those colors

()
{
    local matugen_colors="${XDG_CONFIG_HOME}/zsh/matugen.zsh"
    if [[ ! -f "$matugen_colors" ]] && return 1

    source "$matugen_colors"

    # very important to not have leading whitespace here
    export FZF_DEFAULT_OPTS="--prompt='→ ' --color=\
fg+:$fg_selected,\
bg+:$bg_selected,\
fg:bright-black,\
preview-bg:$preview_bg,\
preview-fg:$preview_fg,\
preview-border:$preview_border,\
list-border:$list_border,\
input-border:$input_border,\
input-label:$input_border,\
hl:$hl:bold,\
hl+:$hl:bold,\
pointer:$pointer,\
info:$list_border:bold,\
gutter:$preview_bg"
}
