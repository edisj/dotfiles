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

export PATH=~/.cargo/bin:$PATH
export PATH=~/opt/bin/:$PATH
export PATH=~/.local/bin:$PATH
export PATH=~/.local/scripts:$PATH
