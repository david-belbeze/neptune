#!/bin/bash

source $NEPTUNE

@test "Test assert raise when exit code is correct" \
    @assert-cmd "neptune.test.@assert-raise file 1" \
    "Test exit code of 'file'
Test 1 == 1" \
    "" 0

@test "Test assert raise when exit code is incorrect" \
    @assert-raise "neptune.test.@assert-raise file 0" 255

