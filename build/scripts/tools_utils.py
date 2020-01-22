#!/usr/bin/env python3
"""tools_utils"""

import json
import argparse
import os


def is_available(tools, name, version):
    """check if a specific tool-version combination exists"""

    # return smallcase true/false to maintain compatibility with the previous
    # version that uses jq.
    if name in tools["programs"]:
        if version in tools["programs"][name]:
            print("true")
        else:
            print("false")
    else:
        print("false")


def get_name_version(tools):
    """return all tool name-version combinations"""

    for tool_name in tools["programs"]:
        for tool_version in tools["programs"][tool_name]:
            print("{tool_name}:{tool_version}".format(
                tool_name=tool_name,
                tool_version=tool_version))

def main():
    """main function"""

    parser = argparse.ArgumentParser(description='tools_utils')
    subparsers = parser.add_subparsers()
    parser_is_tool_avail = subparsers.add_parser("is_available")
    parser_is_tool_avail.add_argument("name", type=str)
    parser_is_tool_avail.add_argument("version", type=str)
    parser_is_tool_avail.set_defaults(func="is_available")

    parser_get_name_version = subparsers.add_parser("get_name_version")
    parser_get_name_version.set_defaults(func="get_name_version")

    params = parser.parse_args()

    script_path = os.path.dirname(os.path.realpath(__file__))
    tool_path = os.path.abspath(os.path.join(script_path,os.pardir,"tools.json"))

    with open(tool_path, "r") as file_in:
        tools = json.load(file_in)
        if params.func == "get_name_version":
            get_name_version(tools)
        elif params.func == "is_available":
            is_available(tools, params.name, params.version)


if __name__ == "__main__":

    main()
