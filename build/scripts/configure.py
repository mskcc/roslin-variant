#!/usr/bin/env python

import os, sys
import ruamel.yaml
from jinja2 import Template
import copy
from subprocess import PIPE, Popen
import requests
import traceback
import shlex

script_path = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.abspath(os.path.join(script_path,os.pardir,os.pardir))

def check_if_module_exists(module_name):
    module_commad = "modulecmd bash load {}".format(str(module_name))
    try:
        single_process = Popen(shlex.split(module_commad), stdout=PIPE,stderr=PIPE, shell=False)
        output, error = single_process.communicate()
        errorcode = single_process.returncode
    except:
        error = traceback.format_exc()
        errorcode = 1
        output = None
    if errorcode != 0:
        print "Error module " + str(module_name) + " could not be loaded.\n"
        if output:
            print "---------- output ----------\n" + str(output)
        if error:
            print "---------- error ----------\n" + str(error)
        exit(1)

def check_if_url_exists(url):
    error = None
    try:
        response = requests.get(url)
        if response.status_code != 200:
            error = "Url "+str(url)+" does not exist. Received response code: " + str(response.status_code)
    except:
        error = traceback.format_exc()
    if error:
        print error
        exit(1)

def load_or_install_dependency(name, version, source_str):
    source_list = source_str.split(":",1)
    if len(source_list) == 1:
        print "Error: Could not parse " + str(source_str) + "\nPlease use the format source_type:source\nFor example: github:https://github.com/dataBiosphere/toil\nAvailable types: path, module, or github"
    source_type = source_list[0].lower()
    source_value = source_list[1]
    dependency_cmd = ''

    if source_type == 'path':
        if not os.path.exists(source_value):
            print "Error: Could not find " + str(source_value)
            exit(1)
        else:
            if name == 'singularity':
                dependency_cmd = 'export ROSLIN_SINGULARITY_PATH="{}"'.format(str(source_value))
            else:
                dependency_cmd = 'cp -r {} $ROSLIN_PIPELINE_RESOURCE_PATH/{}'.format(str(source_value),str(name))
    elif source_type == 'module':
        if name != 'singularity':
            print "Error: Module source type is not supported for " + str(name)
            exit(1)
        module_name = "{}/{}".format(str(source_value),str(version))
        check_if_module_exists(module_name)
        dependency_cmd = "module load {}\nexport ROSLIN_SINGULARITY_PATH=`which {}`".format(str(module_name),str(name))
    elif source_type == 'github':
        if name == 'singularity':
            print "Error: Github source type not supported for singularity"
            exit(1)
        else:
            dependency_cmd = 'cd $ROSLIN_PIPELINE_RESOURCE_PATH\n'
            dependency_cmd = dependency_cmd + "\ngit clone -b {} {} {}".format(str(version),str(source_value),str(name))
    else:
        print "Error: Source type: " + str(source_type) + " not supported. Available types: path, module, or github"
        exit(1)
    if name != 'singularity':
        dependency_cmd = dependency_cmd + "\ncd $ROSLIN_PIPELINE_RESOURCE_PATH/{}".format(str(name))
    if name == 'toil':
        dependency_cmd = dependency_cmd + "\n\t\t\t\tmake prepare\n\t\t\t\tbash -c 'make develop extras=[cwl]'"
    if name == 'cmo':
        dependency_cmd = dependency_cmd + "\n\t\t\t\tpython setup.py install"
    return dependency_cmd

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
        run_env_str = run_env_str + "[ -z '$"+single_env_key+"' ] && export " + single_env_key + '="' + single_env_val + '"\n'

    docker_binding = '-v ' + ' -v '.join([ bind + ':' + bind for bind in filtered_binding_point_list])

    # render
    content = template.render(
        pipeline_description=settings["description"],
        pipeline_name=settings["name"],
        pipeline_version=settings["version"],
        core_min_version=settings["dependencies"]["core"]["version"]["min"],
        core_max_version=settings["dependencies"]["core"]["version"]["max"],
        pipeline_root=os.path.abspath(settings["root"]),
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
            settings["dependencies"]["cmo"]["source"]
        ),
        dependencies_toil_version=settings["dependencies"]["toil"]["version"],
        dependencies_toil_install_path=os.path.join(
            settings["dependencies"]["toil"]["source"]
        ),
        dependencies_singularity_version=settings["dependencies"]["singularity"]["version"],
        load_singularity=load_or_install_dependency('singularity', settings["dependencies"]["singularity"]["version"], settings["dependencies"]["singularity"]["source"]),
        toil_install=load_or_install_dependency('toil', settings["dependencies"]["toil"]["version"], settings["dependencies"]["toil"]["source"]),
        cmo_install=load_or_install_dependency('cmo', settings["dependencies"]["cmo"]["version"], settings["dependencies"]["cmo"]["source"])
    )

    write_to_disk("setup/config/settings.sh", content)

def configure_test_settings(settings):
    template = get_template("setup/config/test-settings.template.sh")
    test_env_str = ""
    for single_env_key, single_env_val in settings["test"]["env"].items():
        test_env_str = test_env_str + "export " + single_env_key + '="' + single_env_val + '"\n'

    content = template.render( test_root=os.path.abspath(settings["test"]["root"]),
        test_tmp=os.path.abspath(settings["test"]["tempDir"]),
        test_batchsystem=settings["test"]["batchsystem"],
        test_cwl_batchsystem=settings["test"]["cwlBatchsystem"],
        test_use_docker=settings["test"]["useDocker"],
        test_docker_registry=settings["test"]["dockerRegistry"],
        test_run_args=settings["test"]["runArgs"],
        test_data_path=os.path.abspath(settings['test']['data_path']),
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
        use_vagrant=settings["build"]["useVagrant"],
        build_cache=os.path.abspath(settings["build"]["buildCache"]),
        load_singularity=load_or_install_dependency('singularity', settings["dependencies"]["singularity"]["version"], settings["dependencies"]["singularity"]["source"])
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
