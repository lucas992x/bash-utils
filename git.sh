#!/bin/bash

# Utility to execute 'git status' or 'git pull' command in many repos at once. Arguments:
# -h: search for subdirectories in current directory
# -d: search for subdirectories in specified directory
# -l: read list of directories from git-list.txt
# -e: exclude subdirectories (listed in a single argumement and separated by space)
# -f: exclude directories reading them from git-exclude.txt
# -s: execute 'git status' command
# -p: execute 'git pull' command
# Examples:
# git.sh -shf
# git.sh -p -d ~/repos
# git.sh -pl -e "tests utils tools"

# utility used to print a line filled with = after each command
print_separator() {
    separator=$(printf '=%.0s' $(seq 1 $(tput cols)))
    echo ""
    echo "$separator"
    echo ""
}
# read args
while getopts "hd:le:fsp" arg; do
    case $arg in
    h)
        entries=$(ls -d */)
        dir="."
        ;;
    d)
        entries=$(ls -d "$OPTARG"/*/)
        dir="$OPTARG"
        ;;
    l)
        entries=()
        # read file line by line
        while read line; do
            entries+=("$line")
        done <"$(dirname "$(realpath $0)")/git-list.txt"
        ;;
    e)
        exclude=()
        readarray -d " " -t items <<<"$OPTARG"
        for ((j = 0; j < ${#items[*]}; j++)); do
            exclude+=("${items[j]}/")
        done
        ;;
    f)
        exclude=()
        # read file line by line
        while read line; do
            exclude+=("$line/")
        done <"$(dirname "$(realpath $0)")/git-exclude.txt"
        ;;
    s)
        command="git status"
        ;;
    p)
        command="git pull"
        ;;
    *)
        exit 1
        ;;
    esac
done

# execute command in directories
if [[ ! -z "$entries" ]]; then
    currentdir=$(pwd) # save current directory
    for entry in ${entries[@]}; do
        # check if there are directories to exclude
        if [[ ! -z $exclude ]]; then
            # check if directory is in excluded items
            if [[ ${exclude[*]} =~ (^|[[:space:]])"${entry/"$dir/"/""}"($|[[:space:]]) ]]; then
                continue
            fi
        fi
        if [[ -d "$entry/.git" ]] && [[ ! -L "$entry/.git" ]]; then
            cd "$entry"
            echo "Executing '$command' command in '$entry'"
            eval $command
            print_separator
        fi
        cd "$currentdir"
    done
fi
