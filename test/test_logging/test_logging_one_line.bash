#!/bin/bash

source $NEPTUNE

# Mock date
date ()
{
    echo "fake_date"
}

@test "Test logging one line" \
    @assert-equals "[fake_date] test.logging.one.line - INFO: The log message" \
    "$(neptune.logging $INFO test.logging.one.line "The log message" 2>&1)"

