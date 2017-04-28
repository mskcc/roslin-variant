#!/usr/bin/python

import json
import argparse


def make_specification(params):
    """make specification"""

    fi = open('specification.template.json', 'r')
    template = json.loads(fi.read())
    fi.close()

    template["InstanceType"] = params.instance_type
    template["Placement"]["AvailabilityZone"] = params.zone

    output = json.dumps(template, indent=4)

    print output

    if params.save:
        fo = open('specification.json', 'w')
        fo.write(output)
        fo.close
        print "Saved."
    else:
        print "Not saved."


def main():
    """main function"""

    parser = argparse.ArgumentParser(description='make_specificatoin')

    parser.add_argument(
        '--zone',
        action="store",
        dest="zone",
        help='Availability zone (e.g. us-east-1c)',
        required=True
    )

    parser.add_argument(
        '--instance-type',
        action="store",
        dest="instance_type",
        help='instance_type (e.g. r4.2xlarge)',
        required=True
    )

    parser.add_argument(
        '--save',
        action="store_true",
        dest="save",
        help='save to specification.json'
    )

    parser.set_defaults(save=False)

    params = parser.parse_args()

    make_specification(params)


if __name__ == "__main__":

    main()
