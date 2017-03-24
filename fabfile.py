from fabric.api import *

env.user = 'chunj'
# env.key_filename = ["~/.ssh/id_rsa"]
env.hosts = ['u36.cbio.mskcc.org']


@task
@hosts('u36.cbio.mskcc.org')
def test():
    """
    test
    """
    run('ls -l')


@task
@hosts('u36.cbio.mskcc.org')
def delete_prism_bin():
    """
    delete everything under ${PRISIM_BIN_PATH}
    """

    run('rm -rf $PRISM_BIN_PATH/*')


@task
@hosts('u36.cbio.mskcc.org')
def half_delete_prism_input():
    """
    delete only files (no directories) in ${PRISIM_INPUT_PATH}/chunj
    """

    run('find $PRISM_INPUT_PATH/chunj -maxdepth 1 -type f -delete')


@task
@hosts('u36.cbio.mskcc.org')
def install(skip_b3=False, skip_compress=False, skip_upload=False):
    """
    install on u36.cbio.mskcc.org
    """

    if not skip_compress:
        local('./compress.sh')

    work_dir = '/home/chunj'

    with cd(work_dir):

        run('mkdir -p prism-setups')

        with cd('prism-setups'):

            if not skip_upload:
                put('prism-v1.0.0.tgz', ".")

            run('mkdir -p 1.0.0')
            run('tar xvzf prism-v1.0.0.tgz -C 1.0.0')

            with cd('1.0.0/setup/scripts'):

                run('./install-production.sh -l')

                pass_envs = ''
                if skip_b3:
                    pass_envs = 'export SKIP_B3=yes && '
                run(pass_envs + './configure-reference-data.sh -l ifs')

