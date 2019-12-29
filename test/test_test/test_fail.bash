#!/bin/bash

source $NEPTUNE

@test "Test neptune.test.@fail without arguments" \
    @assert-cmd "neptune.test.@fail" "AssertFailed" "" 255

@test "Test neptune.test.@fail with reason argument" \
    @assert-cmd "neptune.test.@fail 1 != 0" "AssertFailed:
1 != 0" "" 255

