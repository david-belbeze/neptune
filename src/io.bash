#!/bin/bash

# FONT STYLE
ST_BOLD=1
ST_LIGHT=2
ST_ITALIC=3
ST_UNDERLINE=4

# FOREGROUND COLORS
FG_BLACK=30
FG_RED=31
FG_GREEN=32
FG_YELLOW=33
FG_BLUE=34
FG_MAGENTA=35
FG_CYAN=36
FG_WHITE=37

# BACKGROUND COLORS
BG_BLACK=40
BG_RED=41
BG_GREEN=42
BG_YELLOW=43
BG_BLUE=44
BG_MAGENTA=45
BG_CYAN=46
BG_WHITE=47

# This function allows to stylerize the sequence with the given colors
#
# $1:       The sequence to stylerize
# $2...:    The list of integers to use to stylerize the sequence
# stdout:   The sequence with styles
neptune.style ()
{
    if [ $# -lt 2 ]; then
        echo "ArgumentError: You must provide a message and at least 1 color/style"
        return 1
    fi
    
    local sequence=$1
    
    shift
    #echo "$#" >&2
    until [ $# -le 0 ]; do
        #echo "> $1" >&2
        printf "\033[$1m"
        shift
    done
    printf "$sequence\033[0m"
}

