#!/bin/bash

source $NEPTUNE

# Mock date
date ()
{
    echo "fake_date"
}

@test "Test logging multi lines" \
@assert-equals "[fake_date] test.logging.one.line - INFO: Run \"ls -1\"
    folder1
    folder2
    file1" \
    "$(neptune.logging $INFO test.logging.one.line "Run \"ls -1\"
folder1
folder2
file1" 2>&1)"

