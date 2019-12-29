#!/bin/bash

source $NEPTUNE

@test "Test neptune.style only 1 style"\
    @assert-equals "$(neptune.style "my sequence" $FG_BLUE)" \
        "$(printf "\033[${FG_BLUE}mmy sequence\033[0m")"

@test "Test neptune.style with several styles"\
    @assert-equals "$(neptune.style "my sequence" $FG_BLUE $ST_BOLD)" \
        "$(printf "\033[${FG_BLUE}m\033[${ST_BOLD}mmy sequence\033[0m")"

