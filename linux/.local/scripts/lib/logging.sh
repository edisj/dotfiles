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

LOG_ERROR() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${RED}ERROR${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)][ERROR] $(basename $0): $msg" >&2
    fi
    return 0
}

LOG_WARN() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}] [${YELLOW}WARNING${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)] [WARN] $(basename $0): $msg" >&2
    fi
    return 0
}

LOG_SUCCESS() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${GREEN}SUCCESS${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)][SUCCESS] $(basename $0): $msg" >&2
    fi
    return 0
}

LOG_DONE() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}] [${GREEN}DONE${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)] [DONE] $(basename $0): $msg" >&2
    fi
    return 0
}

LOG_INFO() {
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}] [${BLUE}INFO${EOC}] ${CYAN}$(basename $0)${EOC}: $msg" >&2
    else
        echo -e "[$(timestamp)] [INFO] $(basename $0): $msg" >&2
    fi
    return 0
}
