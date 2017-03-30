from fabric.api import *

# env.user = 'chunj'
# env.key_filename = ["~/.ssh/id_rsa"]
# env.hosts = ['u36.cbio.mskcc.org']


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
@hosts('chunj@u36.cbio.mskcc.org')
def install(skip_b3=False, skip_compress=False, skip_upload=False):
    """
    install on u36.cbio.mskcc.org
    """

    if not skip_compress:
        local('./compress.sh')

    version="1.0.0"

    work_dir = '/home/chunj'

    with cd(work_dir):

        run('mkdir -p prism-setups')

        with cd('prism-setups'):

            if not skip_upload:
                put('prism-v{}.tgz'.format(version), ".")

            run('rm -rf {}'.format(version))
            run('mkdir -p {}'.format(version))
            run('tar xvzf prism-v{0}.tgz -C {0}'.format(version))

            with cd('{}/setup/scripts'.format(version)):

                run('./install-production.sh -l')

                pass_envs = ''
                if skip_b3:
                    pass_envs = 'export SKIP_B3=yes && '
                run(pass_envs + './configure-reference-data.sh -l ifs')


# fab -i ~/mskcc-chunj.pem -u ubuntu -H ec2-52-90-179-143.compute-1.amazonaws.com rsync
@task
def rsync(skip_b3=False):
    """
    rsync to AWS EC2
    """

    version = '1.0.0'

    # make /ifs directory
    run('sudo mkdir -p /ifs && sudo chmod a+w /ifs')

    work_dir = '/tmp/prism-setup-{}'.format(version)

    local('rsync -rave "ssh -i {}" --delete --exclude=".DS_Store" ./setup/ {}@{}:{}'.format(
        env.key_filename[0], env.user, env.host, work_dir))

    with cd("{}/scripts".format(work_dir)):

        run('./install-production.sh -l')

        pass_envs = ''
        if skip_b3:
            pass_envs = 'export SKIP_B3=yes && '
        run(pass_envs + './configure-reference-data.sh -l s3')


# fab -i ~/.ssh/id_rsa -u chunj -H u36.cbio.mskcc.org rsync_luna
@task
def rsync_luna(skip_b3=False):
    """
    rsync to u36
    """

    version = '1.0.0'

    work_dir = '/tmp/prism-setup-{}'.format(version)

    local('rsync -rave "ssh -i {}" --delete --exclude=".DS_Store" ./setup/ {}@{}:{}'.format(
        env.key_filename[0], env.user, env.host, work_dir))

    with cd("{}/scripts".format(work_dir)):

        run('./install-production.sh -l')

        pass_envs = ''
        if skip_b3:
            pass_envs = 'export SKIP_B3=yes && '
        run(pass_envs + './configure-reference-data.sh -l ifs')

