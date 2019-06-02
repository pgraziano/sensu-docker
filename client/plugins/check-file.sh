#!/usr/bin/env bash

if test -f "$1"; then
    echo "OK: file exists: $1"
elif test -d "$1"; then
    echo "OK: directory exists: $1"
else
    echo "FAIL: file not found: $1"
    exit 1
fi
