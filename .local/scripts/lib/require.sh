BLACK="\e[30m"
RED="\e[1;31m"
CYAN="\e[36m"
EOC="\e[0m" # EOC = 'end of color'

require() {
    for cmd in "$@"; do
        if hash "$cmd" &> /dev/null; then
            continue
        fi

        local msg="missing dependency: $cmd"
        local timestamp="$(date +"%H:%M")"
        if [[ -t 1 ]]; then
            echo -e "[${BLACK}$timestamp${EOC}][${RED}ERROR${EOC}] ${CYAN}$(basename $0)${EOC}: $msg"
        else
            echo -e "[$timestamp][ERROR] $(basename $0): $msg"
        fi

        exit 64
    done
}
