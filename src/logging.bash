#!/bin/bash

DEBUG=0
INFO=10
WARNING=20
ERROR=30
CRITICAL=40

if [ -z $LOGGING_LEVEL ]; then
  LOGGING_LEVEL=$INFO
fi

neptune.logging ()
{
  local level=$1
  case $level in
    $DEBUG) type="DEBUG";;
    $INFO) type="INFO";;
    $WARNING) type="WARNING";;
    $ERROR) type="ERROR";;
    $CRITICAL) type="CRITICAL";;
    *)
      echo "ArgumentError:    neptune.logging LOG_LEVEL MODULE_NAME MESSAGE..." >&2
      return 1;;
  esac

  local date=$(date +"%Y-%m-%d %H:%M:%S.%N" | cut -c1-23)
  local module=$2
  
  shift
  shift
  
  if [ $? -ne 0 ]; then
    echo "ArgumentError:    neptune.logging LOG_LEVEL MODULE_NAME MESSAGE..." >&2
    return 1
  fi
  
  if [ $(echo "$@" | wc -l) -gt 1 ]; then
    local message=$(
      echo "$@" | head -n1
      echo "$@" | tail -n+2 | awk '{ print "    "$0}'
    )
  else
    local message="$@"
  fi
  
  if [ $level -ge $LOGGING_LEVEL ]; then
    echo "[$date] $module - $type: $message" >&2
  fi
}

