BLACK="\e[30m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
CYAN="\e[36m"
EOC="\e[0m" # EOC = 'end of color'

timestamp() {
    date +"%H:%M"
}

error() {
    local msg="$1"
    local error_code=${2:-1}
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${RED}ERROR${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)][ERROR] $(basename $0): $msg" >&2
    fi
    return "$error_code"
}

warning() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${YELLOW}WARNING${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)][WARNING] $(basename $0): $msg" >&2
    fi
    return 0
}

success() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${GREEN}SUCCESS${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)][SUCCESS] $(basename $0): $msg" >&2
    fi
    return 0
}

info() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${BLUE}INFO${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)][INFO] $(basename $0): $msg" >&2
    fi
    return 0
}
