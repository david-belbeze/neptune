#!/bin/bash

if [ -z $NEPTUNE ] || [ ! -f $NEPTUNE ]; then
    echo "InitializeError: Impossible to initialize Neptune Framework"
    exit 1
fi

NEPTUNE_BUILTIN=$(dirname $(readlink -f $NEPTUNE))

# Source all files of the neptune Framework
. $NEPTUNE_BUILTIN/logging.bash
. $NEPTUNE_BUILTIN/import.bash
. $NEPTUNE_BUILTIN/io.bash
. $NEPTUNE_BUILTIN/process.bash

# Test framework
. $NEPTUNE_BUILTIN/test.bash

