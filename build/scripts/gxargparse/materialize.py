#!/usr/bin/python

from jinja2 import Template
import argparse
import subprocess


def get_template(filename):
    "read template from file and return jinja template object"

    with open(filename) as template_file:
        return Template(template_file.read())


def materialize(filename, params):
    "read template form disk, render, write back to disk"

    # get template from disk
    template = get_template(filename)

    # render
    content = template.render(
        tool_name=params.tool_name,
        tool_version=params.tool_version,
        tool_command=params.tool_command
    )

    # write to disk
    with open(filename, 'w') as fwrite:
        fwrite.write(content)



def main():
    "main function"

    parser = argparse.ArgumentParser(description='generate cwl')

    parser.add_argument("tool_name")
    parser.add_argument("tool_version")
    parser.add_argument("tool_command")

    params = parser.parse_args()

    map(lambda filename: materialize(filename, params), ["Dockerfile", "gxargparse.sh"])


if __name__ == "__main__":

    main()
