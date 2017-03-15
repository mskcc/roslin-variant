#!/bin/bash


# input example -> bwa:0.7.12
function get_tool_name {
    echo `echo $1 | awk -F':' '{ print $1 }'`
}

# input example -> bwa:0.7.12
function get_tool_version {
    echo `echo $1 | awk -F':' '{ print $2 }'`
}

# input example -> bwa:0.7.12:cmo_bwa_mem
function get_cmo_wrapper_name {
    echo `echo $1 | awk -F':' '{ print $3 }'`
}

function is_tool_available {
    tool_name=$(get_tool_name $1)
    tool_version=$(get_tool_version $1)
    if [ -z $tool_version ]
    then
        echo "false"
        return 1
    fi
    echo `python tools_utils.py is_available $tool_name $tool_version`

    # deprecate: jq version
    # if [ -z $tool_version ]
    # then
    #     echo "false"
    #     return 1
    # fi
    # echo `jq -r "contains(  { programs: { $tool_name: [\"$tool_version\"] } } )" tools.json`
}

# this returns comma-separated list of all tools instalalble
# e.g. samtools:1.3.1,trimgalore:0.4.3
function get_tools_name_version {
    echo `python tools_utils.py get_name_version`

    # deprecate: jq version
    # fixme: there gotta be better way to do this
    # echo `jq -r '.programs | [leaf_paths as $path | { "key": $path[0], "value": getpath($path) }] | .[] | "\(.key):\(.value)"' tools.json`
}

# this returns comma-separated list of all tools instalalble including correspodning cwl wrapper
# e.g. bwa:0.7.12:cmo_bwa_mem,trimgalore:0.4.3:cmo_trimgalore
function get_tools_name_version_cmo {
    echo `python tools_utils.py get_name_version_cmo`
}
