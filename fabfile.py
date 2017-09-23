#!/usr/bin/env python

import os
import yaml
import subprocess
from fabric.api import *


def get_config():
    "read config.yaml into the yaml object and return it"

    with open("config.yaml", "r") as file_handle:
        return yaml.load(file_handle.read())


def get_pipeline_settings_path(config):
    "get path to pipeline settings.sh from yaml config obj"

    return os.path.join(config["root"], config["binding"]["core"], "bin/setup/settings.sh")


def read_core_settings():
    "read the Roslin Core settings"

    command = ['bash', '-c', 'source ./core/config/settings.sh && env']

    proc = subprocess.Popen(command, stdout=subprocess.PIPE)

    source_env = {}

    for line in proc.stdout:
        (key, _, value) = line.partition("=")
        source_env[key] = value.rstrip()

    proc.communicate()

    return source_env


@task
@hosts('u36.cbio.mskcc.org')
def delete_roslin_bin():
    """
    delete everything under ${PRISIM_BIN_PATH}
    """

    run('rm -rf $ROSLIN_PIPELINE_BIN_PATH/*')


@task
@hosts('u36.cbio.mskcc.org')
def half_delete_roslin_input():
    """
    delete only files (no directories) in ${PRISIM_INPUT_PATH}/chunj
    """

    run('find $ROSLIN_PIPELINE_WORKSPACE_PATH/chunj -maxdepth 1 -type f -delete')


@task
def rsync_luna(skip_install=False, skip_ref=False, local_bin_singularity=False):
    """
    fab -i ~/.ssh/mskcc_id_rsa -u chunj -H u36.cbio.mskcc.org rsync_luna
    fab -i ~/.ssh/mskcc_id_rsa -u chunj -H 127.0.0.1:7777 rsync_luna:skip_ref=True,local_bin_singularity=True
    """

    # get configuration from config.yaml
    config = get_config()

    # get pipeline version from configuration
    pipeline_version = config["version"]

    # use /scratch/roslin/ to use the bigger disk
    work_dir = '/scratch/roslin/roslin-setup-{}'.format(pipeline_version)

    run("mkdir -p {}".format(work_dir))

    # rsync
    local(
        'rsync -rave "ssh -i {} -p {}" --delete --exclude=".DS_Store" ./setup/ {}@{}:{}'.format(
            env.key_filename[0],
            env.port,
            env.user, env.host,
            work_dir
        )
    )

    if skip_install:
        print "installation skipped."
    else:
        with cd("{}/scripts".format(work_dir)):

            run('./install-production.sh -l')

            pass_envs = ''
            if skip_ref:
                pass_envs = 'export SKIP_B3=yes && '
            run(pass_envs + './configure-reference-data.sh -l ifs')

    # use /usr/local/bin/singularity instead if necessary
    if local_bin_singularity:
        settings_sh_path = get_pipeline_settings_path(config)
        run('sed -i "s#/usr/bin/singularity#/usr/local/bin/singularity#g" {}'.format(settings_sh_path))


@task
def install_core():
    """
    fab -i ~/.ssh/mskcc_id_rsa -u chunj -H selene.mskcc.org install_core
    """

    core_settings = read_core_settings()

    core_version = core_settings["ROSLIN_CORE_VERSION"]
    work_dir = '/scratch/roslin-{}/install'.format(env.user)

    run('mkdir -m 775 -p {}'.format(work_dir))
    # run('chmod g+w {}'.format(work_dir))

    with lcd("./core"):

        local("./make-deployable-pkg.sh")

        pkg_tgz = 'roslin-core-v{}.tgz'.format(core_version)

        put(pkg_tgz, work_dir, mode=0775)

        with cd(work_dir):

            run('rm -rf core-{}'.format(core_version))
            run('mkdir -m 775 -p core-{}'.format(core_version))

            run('tar xvzf {} -C core-{}'.format(pkg_tgz, core_version))

            with cd("core-{}/bin/install".format(core_version)):

                run('./install-core.sh')
