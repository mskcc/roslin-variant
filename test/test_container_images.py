import subprocess
import json
import os
import re
import ruamel.yaml
from nose.tools import assert_equals
from nose.tools import assert_true
from nose.tools import assert_regexp_matches
from nose.tools import nottest

SING_SCRIPT = "/vagrant/setup/bin/sing/sing.sh"
IMG_PATH = "/vagrant/build/containers/"


def read_from_disk(filename):
    "return file contents"

    with open(filename, 'r') as file_in:
        return file_in.read()


def get_tool_img_path():

    list = []
    with open("/vagrant/build/scripts/tools.json", "r") as file_handle:
        tools_json = json.loads(file_handle.read())
        for tool, versions in tools_json["programs"].iteritems():
            if tool.startswith("@"):
                continue
            for version in versions:
                list.append(os.path.join(IMG_PATH, tool, version, tool + ".img"))

    return list


def get_binding_points():
    "get binding points from config.yaml"

    settings = ruamel.yaml.load(
        read_from_disk("/vagrant/config.yaml"),
        ruamel.yaml.RoundTripLoader
    )

    binding_points = [
        os.path.join(settings["root"], settings["binding"]["core"]),
        os.path.join(settings["root"], settings["binding"]["data"]),
        os.path.join(settings["root"], settings["binding"]["output"])
    ]

    for extra in settings["binding"]["extra"]:
        binding_points.append(os.path.join(settings["root"], extra))

    return binding_points


def test_img_metadata():
    "should have image metadata"

    list_img_path = get_tool_img_path()

    assert_true(len(list_img_path) > 0)

    for img_filename in list_img_path:

        tool_name, tool_version, _ = img_filename.replace(IMG_PATH, "").split("/")
        process = subprocess.Popen(
            ["singularity", "exec", img_filename, "cat", "/.roslin/labels.json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        stdout, _ = process.communicate()

        assert_equals(
            process.returncode,
            0,
            "{} {} ({})".format(tool_name, tool_version, img_filename)
        )

        metadata = json.loads(stdout.rstrip("\n"))

        assert_regexp_matches(
            metadata["version.image"],
            re.compile(r"\b\d+(?:\.[\d\w-]+)*\b"),
            tool_name + " " + tool_version
        )


def test_binding_points():
    "should have correct binding points"

    list_img_path = get_tool_img_path()

    assert_true(len(list_img_path) > 0)

    for img_filename in list_img_path:

        tool_name, tool_version, _ = img_filename.replace(IMG_PATH, "").split("/")

        for binding_point in get_binding_points():
            process = subprocess.Popen(
                ["singularity", "exec", img_filename, "test", "-d", binding_point],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            process.communicate()

            assert_equals(
                process.returncode,
                0,
                "{} {} ({})".format(tool_name, tool_version, img_filename)
            )
