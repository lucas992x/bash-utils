#!/bin/bash

# Utility to execute 'git pull' command in many repos at once. Arguments:
# -h: search for subdirectories in current directory
# -d: search for subdirectories in specified directory
# -l: read list of directories from pull-list.txt
# -e: exclude subdirectories (listed in a single argumement and separated by space)
# -f: exclude directories reading them from pull-exclude.txt
# Examples:
# pull.sh -hf
# pull.sh -d ~/repos
# pull.sh -l -e "tests utils tools"

# read args
while getopts "hd:le:f" arg; do
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
        done <"$(dirname "$(realpath $0)")/pull-list.txt"
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
        done <"$(dirname "$(realpath $0)")/pull-exclude.txt"
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
            echo "Executing 'git pull' command in '$entry'"
            git pull
            echo ""
        fi
        cd "$currentdir"
    done
fi
