#!/bin/bash


# input example -> bwa:0.7.12
function get_tool_name {
    echo `echo $1 | awk -F':' '{ print $1 }'`
}

# input example -> bwa:0.7.12
function get_tool_version {
    echo `echo $1 | awk -F':' '{ print $2 }'`
}

function is_tool_available {
    tool_name=$(get_tool_name $1)
    tool_version=$(get_tool_version $1)
    if [ -z $tool_version ]
    then
        echo "false"
        return 1
    fi
    echo `python $script_dir/tools_utils.py is_available $tool_name $tool_version`
}

# this returns comma-separated list of all tools instalalble
# e.g. samtools:1.3.1,trimgalore:0.4.3
function get_tools_name_version {
    echo `python $script_dir/tools_utils.py get_name_version`
}
