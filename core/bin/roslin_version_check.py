#!/usr/bin/python

import sys
import argparse
from distutils.version import StrictVersion


def main():
    "main function"

    parser = argparse.ArgumentParser(description='submit')

    parser.add_argument(
        "--core-min-version",
        action="store",
        dest="core_min",
        help="Roslin Core minimum version supported",
        required=True
    )

    parser.add_argument(
        "--core-max-version",
        action="store",
        dest="core_max",
        help="Roslin Core maximum version supported",
        required=True
    )

    parser.add_argument(
        "--core-version",
        action="store",
        dest="core_ver",
        help="Roslin Core version to check",
        required=True
    )

    params = parser.parse_args()

    if StrictVersion(params.core_min) <= StrictVersion(params.core_ver) <= StrictVersion(params.core_max):
        # supported
        sys.exit(0)
    else:
        # not supported
        sys.exit(1)


if __name__ == "__main__":

    main()
