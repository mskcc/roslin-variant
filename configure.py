#!/usr/bin/env python

import os, sys
import ruamel.yaml
from jinja2 import Template
import copy


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

def get_deduplicated_binding_points(settings):

    binding_points = [
        os.path.join(settings["root"], settings["binding"]["core"]),
        os.path.join(settings["root"], settings["binding"]["data"]),
        os.path.join(settings["root"], settings["binding"]["output"]),
        os.path.join(settings["root"], settings["binding"]["workspace"])
    ]

    for extra in settings["binding"]["extra"]:
        binding_points.append(os.path.join(settings["root"], extra))

    template = get_template("/vagrant/build/scripts/settings-container.template.sh")

    # remove duplicate binding points

    filtered_binding_point_list = copy.copy(binding_points)

    for single_binding_point in binding_points:
        for other_binding_point in binding_points:
            first_binding_point  = os.path.realpath(single_binding_point)
            second_binding_point = os.path.realpath(other_binding_point)
            if first_binding_point != second_binding_point:
                relative_path = os.path.relpath(first_binding_point,second_binding_point)
                if os.pardir not in relative_path:
                    if single_binding_point in filtered_binding_point_list:
                        filtered_binding_point_list.remove(single_binding_point)

    return filtered_binding_point_list


def configure_setup_settings(settings,filtered_binding_point_list):
    "make /setup/config/settings.sh"

    template = get_template("setup/config/settings.template.sh")

    # render
    content = template.render(
        pipeline_description=settings["description"],
        pipeline_name=settings["name"],
        pipeline_version=settings["version"],
        core_min_version=settings["dependencies"]["core"]["version"]["min"],
        core_max_version=settings["dependencies"]["core"]["version"]["max"],
        pipeline_root=settings["root"],
        binding_core=settings["binding"]["core"],
        binding_data=settings["binding"]["data"],
        binding_output=settings["binding"]["output"],
        binding_workspace=settings["binding"]["workspace"],
        binding_extra=" ".join(settings["binding"]["extra"]),  # to space-separated list
        binding_deduplicated=" ".join(filtered_binding_point_list),
        dependencies_cmo_version=settings["dependencies"]["cmo"]["version"],
        dependencies_cmo_install_path=os.path.join(
            settings["dependencies"]["cmo"]["install-path"]
        ),
        dependencies_toil_version=settings["dependencies"]["toil"]["version"],
        dependencies_toil_install_path=os.path.join(
            settings["dependencies"]["toil"]["install-path"]
        ),
        dependencies_singularity_install_path=settings["dependencies"]["singularity"]["install-path"]
    )

    write_to_disk("setup/config/settings.sh", content)

def configure_test_settings(settings):
    template = get_template("setup/config/test-settings.template.sh")
    test_env_str = ""
    for single_env_key, single_env_val in settings["test"]["env"].items():
        test_env_str = test_env_str + "export " + single_env_key + '="' + single_env_val + '"\n' 

    content = template.render( test_root=settings["test"]["root"],
        test_tmp=settings["test"]["tempDir"],
        test_env=test_env_str
    )

    write_to_disk("setup/config/test-settings.sh", content)

    # Configure our example runs
    run_example_template = get_template("test/run-example.template.sh")
    run_example_content = run_example_template.render(pipeline_name=settings["name"],
        pipeline_version=settings["version"],run_args=settings["test"]["runArgs"])
    write_to_disk("test/run-example.sh",run_example_content)
    run_example_sv_template = get_template("test/run-example-sv.template.sh")
    run_example_sv_content = run_example_sv_template.render(pipeline_name=settings["name"],
        pipeline_version=settings["version"],run_args=settings["test"]["runArgs"])
    write_to_disk("test/run-example-sv.sh",run_example_sv_content)

def configure_build_settings(settings):
    template = get_template("setup/config/build-settings.template.sh")

    content = template.render( build_images=settings["build"]["buildImages"],
        build_vagrant=settings["build"]["vagrantSize"],
        build_threads=settings["build"]["buildThreads"],
        build_core=settings["build"]["installCore"]
    )

    write_to_disk("setup/config/build-settings.sh", content)

def configure_container_settings(settings):
    "make /build/scripts/settings.sh"

    template = get_template("build/scripts/settings-build.template.sh")

    # ------------1
    content = template.render(
        version=settings["version"]
    )

    write_to_disk("build/scripts/settings-build.sh", content)

    # ------------2

    binding_points = [
        os.path.join(settings["root"], settings["binding"]["core"]),
        os.path.join(settings["root"], settings["binding"]["data"]),
        os.path.join(settings["root"], settings["binding"]["output"]),
        os.path.join(settings["root"], settings["binding"]["workspace"])
    ]

    for extra in settings["binding"]["extra"]:
        binding_points.append(os.path.join(settings["root"], extra))

    template = get_template("build/scripts/settings-container.template.sh")

    # render
    content = template.render(
        binding_points=" ".join(filtered_binding_point_list)  # to space-separated list
    )

    write_to_disk("build/scripts/settings-container.sh", content)


def main():
    "main function"

    if len(sys.argv) < 2:
	print "USAGE: config.py configuration_file.yaml"
	exit()

    settings = ruamel.yaml.load(
        read_from_disk(sys.argv[1]),
        ruamel.yaml.RoundTripLoader
    )

    filtered_binding_point_list = get_deduplicated_binding_points(settings)

    configure_setup_settings(settings,filtered_binding_point_list)

    configure_build_settings(settings)

    configure_test_settings(settings)

    configure_container_settings(settings)


if __name__ == "__main__":

    main()
