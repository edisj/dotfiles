readonly BLACK="\e[30m"
readonly RED="\e[1;31m"
readonly GREEN="\e[1;32m"
readonly YELLOW="\e[1;33m"
readonly BLUE="\e[1;34m"
readonly CYAN="\e[36m"
readonly EOC="\e[0m" # EOC = 'end of color'

timestamp()
{
    date +"%H:%M"
}

error()
{
    local msg="$1"
    local error_code=${2:-1}
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${RED}ERROR${EOC}] ${CYAN}$(basename $0)${EOC}: $msg"
    else
        echo -e "[$(timestamp)][ERROR] $(basename $0): $msg"
    fi
    exit "$error_code"
}

warning()
{
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${YELLOW}WARNING${EOC}] ${CYAN}$(basename $0)${EOC}: $msg"
    else
        echo -e "[$(timestamp)][WARNING] $(basename $0): $msg"
    fi
    return 0
}

success()
{
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${GREEN}SUCCESS${EOC}] ${CYAN}$(basename $0)${EOC}: $msg"
    else
        echo -e "[$(timestamp)][SUCCESS] $(basename $0): $msg"
    fi
    return 0
}

info()
{
    local msg="$1"
    if [[ -t 1 ]]; then
        echo -e "[${BLACK}$(timestamp)${EOC}][${BLUE}INFO${EOC}] ${CYAN}$(basename $0)${EOC}: $msg"
    else
        echo -e "[$(timestamp)][INFO] $(basename $0): $msg"
    fi
    return 0
}
