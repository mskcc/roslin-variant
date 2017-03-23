#!/usr/bin/python
"""update_resource_def"""

import json
import argparse


def main():
    """main function"""

    parser = argparse.ArgumentParser(description='update_resource_def')

    parser.add_argument(
        '-f',
        action='store',
        dest='filename',
        help='path to prism.json',
        default='prism.json'
    )

    parser.add_argument("tool_name")
    parser.add_argument("tool_version")
    parser.add_argument("tool_path")

    params = parser.parse_args()

    definitions = ""

    # read form file
    with open(params.filename, "r") as file_in:
        definitions = json.load(file_in)

    # update
    definitions["programs"][params.tool_name][params.tool_version] = params.tool_path

    # write back to file
    with open(params.filename, "w") as file_out:
        file_out.write(json.dumps(definitions, indent=4, sort_keys=True))


if __name__ == "__main__":

    main()

