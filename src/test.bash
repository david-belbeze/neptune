#!/bin/bash

# This method execute a test.
#
# - $1:     The message of the test
# - $2...:  The assert test to execute
# - return 0 when the test is passed
# - exit 1 when bad arguments
# - exit 255 When test failed
@test () {
    echo $(($(cat /tmp/neptune-test-count) + 1)) > /tmp/neptune-test-count
    # Test that ther is more than 2 arguments
    if [[ $# -lt 2 ]]; then
        echo "TestError: You must provide more than 2 arguments"
        exit 1
    fi
    
    printf "\033[1m$1\033[0m\n"
    shift
    
    # Execute test
    if [[ -f $NEPTUNE_TEST_STDIN ]]; then
        test_result=$(cat $NEPTUNE_TEST_STDIN | neptune.test."$@") 
        exit_code=$?
    else
        test_result=$(neptune.test."$@") 
        exit_code=$?
    fi
    
    echo "$test_result" | while read line; do
        printf "\033[36m>>> $line\033[0m\n" >&2
    done
    
    # When error exit with test code
    if [[ $exit_code -ne 0 ]]; then 
        printf "\033[1m\033[31mKO\033[0m\n"
        exit $exit_code; 
    else
        printf "\033[1m\033[32mOK\033[0m\n"
    fi
    
    # Reset test variables
    export NEPTUNE_TEST_STDIN=''
}


# This method allows to skip a test, nothing is performed in this function
@test.skip () {
    true
}


# This method allows to fail the current test
#
# - $1: [Optional] the message to push in stderr
# - exit 255 When test failed
neptune.test.@fail ()
{
    if [[ ! -z $1 ]]; then
        echo -e "AssertFailed:\n$@"
    else
        echo "AssertFailed"
    fi
    exit 255
}


# This function test if the parameter is true
#
# - $1: an integer where 0 means false and other means true
# - return 0 when the test is passed
# - exit 1 when bad arguments
# - exit 255 when test failed
neptune.test.@assert ()
{
    if [[ -z $1 ]]; then
        echo "AssertError: you must provide an argument to test"
        return 1
    fi

    echo "Test '$1'"

    if (( $1 )); then
        return 0
    else
        neptune.test.@fail "'$1' == 0"
    fi
}


# This function allows to test the exit code or the return
# code of a command line
#
# - $1: command line to execute
# - $2: expected code
# - return 0 when the test is passed
# - exit 1 when bad arguments
# - exit 255 when test failed
neptune.test.@assert-raise ()
{
    if [[ -z $1 || ! $2 =~ ^[0-9]+$ ]]; then
        echo "AssertError: you must provide 2 arguments to test the command exit code"
        exit 1
    fi
    
    echo "Test exit code of '$1'"
    _=$($1 >/dev/null 2>&1)
    
    # Test the exit code
    neptune.test.@assert-int-equals $2 $?
}


# This function test the string sequence equality
#
# - $1: expected string
# - $2: string to test
# - return 0 when the test is passed
# - exit 1 when bad arguments
# - exit 255 when test failed
neptune.test.@assert-equals ()
{
    if [[ $# -ne 2 ]]; then
        echo "AssertError: You must provide 2 arguments to test for string equality"
        exit 1
    fi
    
    echo "Test '$1' == '$2'"

    if [[ "$1" == "$2" ]]; then
        return 0
    else
        neptune.test.@fail "Expected:   '$1'
Given:      '$2'"
    fi
}


# This function test the integers equality
#
# - $1: expected string
# - $2: string to test
# - return 0 when the test is passed
# - exit 1 when bad arguments
# - exit 255 when test failed
neptune.test.@assert-int-equals ()
{
    if [[ $# -ne 2 ]]; then
        echo "AssertError: You must provide 2 arguments to test for integer equality"
        exit 1
    fi
    
    echo "Test $1 == $2"

    if [[ $1 -ne $2 ]]; then
        neptune.test.@fail "Expected:   '$1'
Given:      '$2'"
    fi
}


# This function allows to test a command line, bin or any shell function.
#
# - $1: command line as string
# - $2: expected stdout
# - $3: expected stderr
# - $4: expected exit code
# - return 0 when the test is passed
# - exit 1 when bad arguments
# - exit 255 when test failed
neptune.test.@assert-cmd ()
{
    if [[ $# -ne 4 ]]; then
        echo "AssertError: You must provide 4 arguments to test the command"
        exit 1
    fi
    
    echo "Test the command '$1'"
    # Execute in sub shell the command
    _=$($1 >/tmp/neptune-test-stdout 2>/tmp/neptune-test-stderr)
    
    cmd_exit_code=$?
    
    echo "Test stdout"
    neptune.test.@assert-equals "$2" "$(cat /tmp/neptune-test-stdout)"
    echo "Test stderr"
    neptune.test.@assert-equals "$3" "$(cat /tmp/neptune-test-stderr)"
    
    echo "Test exit code"
    neptune.test.@assert-int-equals $cmd_exit_code $4
}

