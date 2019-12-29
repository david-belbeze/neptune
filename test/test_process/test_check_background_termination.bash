#!/bin/bash

source $NEPTUNE

echo "--${ID_TEST}-start
$ long-process" > /tmp/neptune-${ID_TEST}-execution

# Test 1
@test "Test neptune.process__check-background-termination for running process" \
    @assert-equals "" \
        "$(neptune.process__check-background-termination $ID_PARALLEL $ID_TEST)"

# Prepare second file
echo "--${ID_TEST}-start
$ long-process
stdout:
    OK
stderr:
exit code: 0
--${ID_TEST}-end (10s)" > /tmp/neptune-${ID_TEST}-execution

# Test 2
@test "Test neptune.process__check-background-termination for completed process" \
    @assert-equals "/tmp/neptune-${ID_TEST}-execution" \
        "$(neptune.process__check-background-termination $ID_PARALLEL $ID_TEST)"

# Clean file
rm /tmp/neptune-${ID_TEST}-execution /tmp/neptune-$ID_PARALLEL-exec

