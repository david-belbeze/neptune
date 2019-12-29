#!/bin/bash

source $NEPTUNE

@test "Test neptune.style no argument"\
    @assert-raise "neptune.style" 1

@test "Test neptune.style with only the sequence"\
    @assert-raise 'neptune.style "sequence"' 1

