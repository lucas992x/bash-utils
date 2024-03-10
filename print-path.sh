#!/bin/bash

# A simple script that prints PATH one item per line

readarray -d ":" -t items < <(printf '%s' "$PATH")
for ((j = 0; j < ${#items[*]}; j++)); do
    echo "${items[j]}"
done
