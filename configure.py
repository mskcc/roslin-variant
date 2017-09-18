#!/usr/bin/env python

import os
import ruamel.yaml
from jinja2 import Template


def read_from_disk(filename):
    "return file contents"

    with open(filename, 'r') as file_in:
        return file_in.read()


def write_to_disk(filename, content):
    "write to file"

    with open(filename, 'w') as file_out:
        file_out.write(content)

    print "Modified: {}".format(filename)


def get_template(filename):
    "read template from file and return jinja template object"

    with open(filename) as template_file:
        return Template(template_file.read())


def configure_setup_settings(settings):
    "make /setup/scripts/settings.sh"

    template = get_template("/vagrant/setup/scripts/settings.template.sh")

    # render
    content = template.render(
        core_min_version=settings["dependencies"]["core"]["version"]["min"],
        core_max_version=settings["dependencies"]["core"]["version"]["max"],
        pipeline_name=settings["name"],
        pipeline_version=settings["version"],
        pipeline_root=os.path.join(settings["root"], settings["version"]),
        binding_core=settings["binding"]["core"],
        binding_data=settings["binding"]["data"],
        binding_output=settings["binding"]["output"],
        binding_workspace=settings["binding"]["workspace"],
        binding_extra=" ".join(settings["binding"]["extra"]),  # to space-separated list
        dependencies_cmo_version=settings["dependencies"]["cmo"]["version"],
        dependencies_cmo_python_path=settings["dependencies"]["cmo"]["python-path"]
    )

    write_to_disk("/vagrant/setup/scripts/settings.sh", content)


def configure_build_settings(settings):
    "make /build/scripts/settings.sh"

    template = get_template("/vagrant/build/scripts/settings-build.template.sh")

    # ------------1
    content = template.render(
        version=settings["version"]
    )

    write_to_disk("/vagrant/build/scripts/settings-build.sh", content)

    # ------------2

    binding_points = [
        os.path.join(settings["root"], settings["binding"]["core"]),
        os.path.join(settings["root"], settings["binding"]["data"]),
        os.path.join(settings["root"], settings["binding"]["output"]),
        os.path.join(settings["root"], settings["binding"]["workspace"])
    ]

    for extra in settings["binding"]["extra"]:
        binding_points.append(os.path.join(settings["root"], extra))

    template = get_template("/vagrant/build/scripts/settings-container.template.sh")

    # render
    content = template.render(
        binding_points=" ".join(binding_points)  # to space-separated list
    )

    write_to_disk("/vagrant/build/scripts/settings-container.sh", content)


def main():
    "main function"

    settings = ruamel.yaml.load(
        read_from_disk("config.yaml"),
        ruamel.yaml.RoundTripLoader
    )

    configure_setup_settings(settings)

    configure_build_settings(settings)


if __name__ == "__main__":

    main()
