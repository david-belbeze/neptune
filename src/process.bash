#!/bin/bash

# This module contains functions that help to execute multiple
# process in parallel

# This function allows to perform execution of command in parallel
# and wait the termination of all prcocesses
#
# stdin:    The list of command to execute in parallel
# stdout:   The list of files that contains the process execution
neptune.process-parallel ()
{
    local id=$(uuidgen)
    
    # Save the command to play in a file
    if [[ ! -t 0 ]]; then
        rm /tmp/neptune-$id-cmd 2>/dev/null
        while read -r line; do
            echo $line >> /tmp/neptune-$id-cmd.tmp
        done
    fi
    
    # Stop the function is no commands are found
    cat /tmp/neptune-$id-cmd.tmp | grep -v -w "" > /tmp/neptune-$id-cmd
    rm /tmp/neptune-$id-cmd.tmp
    if [[ $(cat /tmp/neptune-$id-cmd | wc -l) -eq 0 ]]; then
        neptune.logging $WARNING neptune.process-parallel "No commands provided to be executed in parallel"
        return 0
    fi
    
    # Control the argument for number of maximum processes
    if [[ $# -eq 0 ]]; then
        local maxproc=$(nproc --all)
    elif [[ $1 =~ ^[0-9]+$ ]]; then
        local maxproc=$1
    else
        logging $ERROR neptune.process-parallel "The first argument must be an integer"
        exit 1
    fi
    
    neptune.logging $DEBUG neptune.process-parallel \
        "${maxproc} proccess maximum in parallel"
    
    # While there is commands to execute or process in execution
    touch /tmp/neptune-$id-exec
    while [[ $(cat /tmp/neptune-$id-cmd | wc -l) -gt 0 ||
        $(cat /tmp/neptune-$id-exec | wc -l) -gt 0 ]]; do
        
        # Start process in background
        while [[ $(cat /tmp/neptune-$id-cmd | wc -l) -gt 0 &&
            $(cat /tmp/neptune-$id-exec | wc -l) -lt $maxproc ]]; do
            neptune.process__start-background-next $id
        done
        
        # Control process termination
        process_ids=$(cat /tmp/neptune-$id-exec)
        echo "${process_ids}" | while read -r process_id; do
            # Check the termination of the process id
            neptune.process__check-background-termination $id $process_id
        done
        
        # Wait 0.25 seconds before new check
        sleep 0.25
    done
    
    # Clean temporary files
    rm /tmp/neptune-$id-cmd /tmp/neptune-$id-exec 2>/dev/null
}

# This function start a new process in background
#
# $1:   The id of the parallel execution
neptune.process__start-background-next ()
{
    # Get the next command
    local command=$(cat /tmp/neptune-$1-cmd | head -n1)
    
    # Remove the command from the list of commands
    neptune.logging $DEBUG start-background-next \
        "Remove the command line '$command' from list of commands"
    cat /tmp/neptune-$1-cmd | tail -n+2 > /tmp/neptune-$1-cmd.tmp
    mv /tmp/neptune-$1-cmd.tmp /tmp/neptune-$1-cmd
    
    local process_id=$(echo ${1}$(uuidgen) | sha1sum | cut -d " " -f1)
    
    # Register the id of the process for background termination
    neptune.logging $DEBUG start-background-next \
        "Register a new background process with id ${process_id}"
    echo $process_id >> /tmp/neptune-$1-exec
    
    # Start command in sub shell
    neptune.logging $INFO start-background-next \
        "Start the background process ${process_id}: ${command}"
    # Write the script in file
    echo "start_time=\$(date +%s)
echo \"--$process_id-start\"
echo \"\$ ${command}\"
$command >/tmp/neptune-$process_id-stdout 2>/tmp/neptune-$process_id-stderr
exit_code=\$?
echo \"stdout\"
cat /tmp/neptune-$process_id-stdout | awk '{ print "    "\$0}'
echo \"stderr\"
cat /tmp/neptune-$process_id-stderr | awk '{ print "    "\$0}'
echo \"exit code: ${exit_code}\"
echo \"--$process_id-end (\$(( \$(date +%s) - \$start_time ))s)\"" \
        > /tmp/neptune-$process_id.sh
    
    neptune.logging $DEBUG start-background-next "Content of sub script:
$(cat /tmp/neptune-$process_id.sh)"
    # Start the script in background
    sh /tmp/neptune-$process_id.sh > /tmp/neptune-$process_id-execution &
}

# This function wait the termination of one process and clear
# temporary files attached to the process
#
# $1:       The id of the parallel execution
# $2:       The id of the process to look
# stdout:   The file path that contains the log of the process executed in background
neptune.process__check-background-termination ()
{
    # Read the logs to know if the process is completed or not
    if [[ ! -z $(cat /tmp/neptune-${2}-execution | egrep "^--${2}-end \([0-9]+s\)$") ]];
    then
        # The process is completed
        neptune.logging $INFO check-background-termination \
            "The background process ${2} is completed"
        # Remove the background process
        neptune.logging $DEBUG check-background-termination \
            "Remove The background process id ${2} from the parallel execution"\
            "process list"
        cat /tmp/neptune-${1}-exec | grep -v "${2}" > /tmp/neptune-${1}-exec.tmp
        mv /tmp/neptune-${1}-exec.tmp /tmp/neptune-${1}-exec

        # Clean temporary resources
        rm /tmp/neptune-${2}-stdout \
            /tmp/neptune-${2}-stderr\
            /tmp/neptune-${2}.sh 2>/dev/null
        
        echo /tmp/neptune-${2}-execution
    fi
}

