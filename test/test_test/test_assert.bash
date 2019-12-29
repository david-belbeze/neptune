#!/bin/bash

source $NEPTUNE

@test 'Test "true"' \
    @assert 1
@test 'Test "true"' \
    @assert 127
@test 'Test "true"' \
    @assert -379

@test 'Test "false"' \
    @assert-raise "neptune.test.@assert 0" 255 

