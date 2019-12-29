#!/bin/bash

source $NEPTUNE

# Mock date
date ()
{
    echo "fake_date"
}


export LOGGING_LEVEL=$WARNING

@test "Test logging level hidden" \
    @assert-equals "" \
    "$(neptune.logging $INFO test.logging.one.line "The log message" 2>&1)"

@test "Test logging level displayed same level" \
    @assert-equals "[fake_date] test.logging.one.line - WARNING: The log message" \
    "$(neptune.logging $WARNING test.logging.one.line "The log message" 2>&1)"

@test "Test logging level displayed level over" \
    @assert-equals "[fake_date] test.logging.one.line - CRITICAL: The log message" \
    "$(neptune.logging $CRITICAL test.logging.one.line "The log message" 2>&1)"

