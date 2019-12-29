#!/bin/bash

source $NEPTUNE

echo "
" > /tmp/neptune-test-stdin

export NEPTUNE_TEST_STDIN=/tmp/neptune-test-stdin

# Test empty stdin
@test "Test 0 process in stdin for process parrallel"\
    @assert-raise "neptune.process-parallel" 0

rm /tmp/neptune-test-stdin

# Test multiple processes

for _ in {1..20}; do
    echo "sleep 0.5" >> /tmp/neptune-test-stdin
done

@test "Test 0 process in stdin for process parrallel"\
    @assert-int-equals \
        $(cat /tmp/neptune-test-stdin | neptune.process-parallel 10 | wc -l) 20

