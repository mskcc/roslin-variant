#!/usr/bin/env python

import os, sys
import ruamel.yaml
from jinja2 import Template
import copy

script_path = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.abspath(os.path.join(script_path,os.pardir,os.pardir))

def read_from_disk(filename):
    "return file contents"
    template_path = os.path.join(root_dir,filename)
    with open(template_path, 'r') as file_in:
        return file_in.read()


def write_to_disk(filename, content):
    "write to file"
    template_path = os.path.join(root_dir,filename)
    with open(template_path, 'w') as file_out:
        file_out.write(content)

    print "Modified: {}".format(filename)


def get_template(filename):
    "read template from file and return jinja template object"
    template_path = os.path.join(root_dir,filename)
    with open(template_path) as template_file:
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
    template = get_template("setup/config/settings.template.sh")
    run_env_str = ""

    for single_env_key, single_env_val in settings["env"].items():
        run_env_str = run_env_str + "export " + single_env_key + '="' + single_env_val + '"\n'

    docker_binding = '-v ' + ' -v '.join([ bind + ':' + bind for bind in filtered_binding_point_list])

    # render
    content = template.render(
        pipeline_description=settings["description"],
        pipeline_name=settings["name"],
        pipeline_version=settings["version"],
        core_min_version=settings["dependencies"]["core"]["version"]["min"],
        core_max_version=settings["dependencies"]["core"]["version"]["max"],
        pipeline_root=settings["root"],
        run_env=run_env_str,
        binding_core=settings["binding"]["core"],
        binding_data=settings["binding"]["data"],
        binding_output=settings["binding"]["output"],
        binding_workspace=settings["binding"]["workspace"],
        binding_extra=" ".join(settings["binding"]["extra"]),  # to space-separated list
        binding_deduplicated=",".join(filtered_binding_point_list),
        docker_binding=docker_binding,
        dependencies_cmo_version=settings["dependencies"]["cmo"]["version"],
        dependencies_cmo_install_path=os.path.join(
            settings["dependencies"]["cmo"]["install-path"]
        ),
        dependencies_toil_version=settings["dependencies"]["toil"]["version"],
        dependencies_toil_install_path=os.path.join(
            settings["dependencies"]["toil"]["install-path"]
        ),
        dependencies_singularity_version=settings["dependencies"]["singularity"]["version"],
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
        test_batchsystem=settings["test"]["batchsystem"],
        test_cwl_batchsystem=settings["test"]["cwlBatchsystem"],
        test_use_docker=settings["test"]["useDocker"],
        test_docker_registry=settings["test"]["dockerRegistry"],
        test_run_args=settings["test"]["runArgs"],
        test_data_path=settings['test']['data_path'],
        test_data_url=settings['test']['data_url'],
        test_env=test_env_str
    )

    write_to_disk("setup/config/test-settings.sh", content)

def configure_build_settings(settings):
    template = get_template("setup/config/build-settings.template.sh")

    content = template.render( build_threads=settings["build"]["buildThreads"],
        build_core=settings["build"]["installCore"],
        build_docker=settings["build"]["buildDocker"],
        build_singularity=settings["build"]["buildSingularity"],
        docker_registry=settings["build"]["dockerRegistry"],
        docker_push=settings["build"]["dockerPush"],
        use_vagrant=settings["build"]["useVagrant"]
    )

    write_to_disk("setup/config/build-settings.sh", content)

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

if __name__ == "__main__":

    main()
