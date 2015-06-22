#!/bin/bash
################################################################################
# Takes input from a pipe.
# Appends current date to every line of input
appendDate()
{
    ( while IFS= read -r line ; do printf "%s %s\n" "$(date +%D_%H:%M:%S):" "$line" ; done )
}