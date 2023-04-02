#!/bin/bash

# This script reads a list of git repositories from text file and clones them (a
# repository is not cloned if destination directory already esists). Each line
# should contain one HTTPS URL; it is possible to specify the directory where it
# will be cloned (it must not contain spaces). See clone.txt.sample for examples.

# get script directory
script_dir="$(dirname "$(realpath $0)")"

# read file line by line
while read line; do
    if [[ ! -z "$line" ]]; then
        if [[ "$line" == *" "* ]]; then
            dest_dir="${line/*" "/""}"
        else
            dest_dir="${line/*"/"/""}"
            dest_dir="${dest_dir/".git"/""}"
        fi
        if [[ ! -d "$dest_dir" ]]; then
            git clone $line
        else
            echo "'$dest_dir' already exists, skipping it"
        fi
    fi
done <"$script_dir"/clone.txt
