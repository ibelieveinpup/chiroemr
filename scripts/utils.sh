#!/bin/bash
# utils.sh - Common helper functions for chiroemr scripts

# Abort if sourced twice (optional safety)
[ -n "$_CHIROEMR_UTILS_LOADED" ] && return
_CHIROEMR_UTILS_LOADED=1

# Check if directory contains at least one subdirectory
has_subdirs() {
    local dir="$1"
    find "$dir" -mindepth 1 -maxdepth 1 -type d | grep -q .
}

check_visit_path() {
	if [[ -z $VISIT_PATH ]]; then
	echo "Error!  Must set \$VISIT_PATH first: source visit_path_setter.sh"
	exit 1
	fi
}

# Pretty banner message
banner() {
    echo "==== $* ===="
}

# Colored echo (optional)
cecho() {
    local color="$1"; shift
    case "$color" in
        red)    code=31 ;;
        green)  code=32 ;;
        yellow) code=33 ;;
        blue)   code=34 ;;
        *)      code=0 ;;
    esac
    echo -e "\033[${code}m$*\033[0m"
}

