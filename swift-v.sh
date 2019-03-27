#!/bin/bash

binary_path=$1

otool_command=`otool -l ${binary_path}`
IFS=$'\n'; # TODO: Assumes otool output does not contain '\n'
otool_output_lines=( ${otool_command} );
otool_output_lines_len=${#otool_output_lines[@]}

contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

index=-1
for line in "${otool_output_lines[@]}";
do
    index=$((index+1))
    found_load_command=false
    contains "$line" "Load command" && found_load_command=true
    if "$found_load_command"; then

        # populate
        name=''
        current=''

        sub_search_index=index
        sub_found_load_command=0

        until [ "$sub_found_load_command" -eq 1 ]; do

            # move on
            sub_search_index=$((sub_search_index+1))
            current_line=${otool_output_lines[$sub_search_index]}

            # get data if exists
            contains "$current_line" "name" && name="$current_line"
            contains "$current_line" "current" && current="$current_line"

            # quit if reached the next Load command
            contains "$current_line" "Load command" && sub_found_load_command=1
            
            # guard against going off the edge
            if [ "$sub_search_index" -gt "$otool_output_lines_len" ] 
            then
                sub_found_load_command=1
            fi
        done

        printf "Found name: %s\n" "$name"
        printf "Found current: %s\n" "$current"

    fi
done