#!/usr/bin/python
"""tools_utils"""

import json
import argparse


def is_available(tools, name, version):
    """check if a specific tool-version combination exists"""

    # return smallcase true/false to maintain compatibility with the previous
    # version that uses jq.
    if name in tools["programs"]:
        print "true" if version in tools["programs"][name] else "false"
    else:
        print "false"


def get_name_version(tools):
    """return all tool name-version combinations"""

    for tool_name in tools["programs"]:
        for tool_version in tools["programs"][tool_name]:
            print "{tool_name}:{tool_version}".format(
                tool_name=tool_name,
                tool_version=tool_version)


def get_name_version_cmo(tools):
    """return all tool name-version-cmo combinations"""

    for tool_name in tools["containerDependency"]:
        for cmo_wrapper in tools["containerDependency"][tool_name]:
            for tool_version in tools["programs"][tool_name]:
                print "{tool_name}:{tool_version}:{cmo_wrapper}".format(
                    tool_name=tool_name,
                    tool_version=tool_version,
                    cmo_wrapper=cmo_wrapper)


def main():
    """main function"""

    parser = argparse.ArgumentParser(description='tools_utils')
    subparsers = parser.add_subparsers()

    parser.add_argument(
        '-f',
        action='store',
        dest='filename',
        help='Filename of the JSON tools definition',
        default='tools.json'
    )

    parser_is_tool_avail = subparsers.add_parser("is_available")
    parser_is_tool_avail.add_argument("name", type=str)
    parser_is_tool_avail.add_argument("version", type=str)
    parser_is_tool_avail.set_defaults(func="is_available")

    parser_get_name_version = subparsers.add_parser("get_name_version")
    parser_get_name_version.set_defaults(func="get_name_version")

    parser_get_name_version_cmo = subparsers.add_parser("get_name_version_cmo")
    parser_get_name_version_cmo.set_defaults(func="get_name_version_cmo")

    params = parser.parse_args()

    with open(params.filename, "r") as file_in:
        tools = json.load(file_in)
        if params.func == "get_name_version_cmo":
            get_name_version_cmo(tools)
        elif params.func == "get_name_version":
            get_name_version(tools)
        elif params.func == "is_available":
            is_available(tools, params.name, params.version)


if __name__ == "__main__":

    main()
