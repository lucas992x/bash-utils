#!/bin/bash

# This script configures aliases, exports and PATH reading them from text
# file(s): each one should be located in same directory of this script and is
# used only if exists (examples are provided).
# First file to be read is config-shell-<arg>.txt, where <arg> is $1: this can
# be useful when having multiple installations where each one has specific
# stuff, its content is added as-is to aliases file.
# Second file is config-shell-exports.txt, which should contain exported
# variables. Its content is added as-is to aliases file.
# Third file is config-shell-aliases.txt, which should contain aliases. Its
# content is added as-is to aliases file.
# Fourth file is config-shell-path.txt, which adds directories to PATH. Each
# line should contain a directory (variables can be used).

# get script directory
dir="$(dirname "$(realpath $0)")"
# set destination file
destfile=~/.bash_aliases
# clear dest file
>"$destfile"
# check if installation-specific file is provided
if [[ ! -z "$1" ]]; then
    echo "$(cat "$dir"/config-shell-$1.txt)" >>"$destfile"
fi
# get exports
if [[ -f "$dir/config-shell-exports.txt" ]]; then
    echo "" >>"$destfile"
    echo "# exports" >>"$destfile"
    echo "$(cat "$dir"/config-shell-exports.txt)" >>"$destfile"
fi
# get aliases
if [[ -f "$dir/config-shell-aliases.txt" ]]; then
    echo "" >>"$destfile"
    echo "# aliases" >>"$destfile"
    echo "$(cat "$dir"/config-shell-aliases.txt)" >>"$destfile"
fi
# add directories to PATH
if [[ -f "$dir/config-shell-path.txt" ]]; then
    echo "" >>"$destfile"
    echo "# add to PATH" >>"$destfile"
    paths="export PATH="
    while read line; do
        paths+="$line:"
    done <"$dir/config-shell-path.txt"
    paths+="\$PATH"
    echo "$paths" >>"$destfile"
fi
# config ~/.bashrc if needed
text="
# alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi"
if [[ "$(cat ~/.bashrc)" != *". ~/.bash_aliases"* ]]; then
    echo "$text" >>~/.bashrc
fi
# update
. ~/.bashrc
