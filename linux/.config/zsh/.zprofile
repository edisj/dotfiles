# Startup sequence:
# 1) .zenv
# 2) .zprofile <-
# 3) .zshrc
# 4) .zlogin
# 5) .zlogout
#
# zprofile is sourced only in login shells
#
# I set PATH here because macOS does weird stuff with PATH

# echo "entering .zprofile"

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/opt/bin/:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"

if command -v hyprctl &> /dev/null; then
    export PATH="$HOME/.config/hypr/bin:$PATH"
fi
