# Roslin-variant

Roslin-variant is a reproducible and reusable workflow for Cancer Genomic Sequencing Analysis

## Prerequisites

To build, deploy, and use Roslin, you will need:

- [Python 3](https://packages.ubuntu.com/bionic/python3)
- [Python3-dev](https://packages.ubuntu.com/bionic/python3-dev)
- [Singularity 3.3.0+](https://sylabs.io/guides/3.0/user-guide/installation.html#distribution-packages-of-singularity)
- [MongoDB 3.0.15+](https://docs.openstack.org/project-install-guide/meter/newton/database/environment-nosql-database-rdo.html)

Most testing of Roslin has been done with the specific versions above on hosts running CentOS 7.6. If you run into problems, search through [the issues](../../issues) for related solutions. If you cannot solve the problem without our help, then please create a [new issue](../../issues/new) with detailed information on how to reproduce your problem.

## Installation

Clone the repo, switch to the current branch, init and update submodules:
```
git clone --branch 2.6.x --recurse-submodules https://github.com/mskcc/roslin-variant.git
```

Enter the repo and edit the configuration files as appropriate for your host/environment. At minimum, enter your MongoDB admin user/password in `core/config.core.yaml`:
```
cd roslin-variant
vi core/config.core.yaml
vi config.variant.yaml
```

Users of the Juno cluster at MSKCC, can simply copy [sample-juno-config.yaml](sample-juno-config.yaml) instead:
```
cp sample-juno-config.yaml config.variant.yaml
```

1. Add the root with the path where you want to install the pipeline
2. Modify `TOIL_LSF_ARGS` within both root and test env's as appropriate

You can use `TOIL_LSF_ARGS` to run all your jobs under a SLA or increase walltime. For example:
```
TOIL_LSF_ARGS: '-sla jvSC -W 168:00'
```

Here is a table containing the description of important keys in `core/config.core.yaml`:

| Key       | Description       |
| :------------- |:-------------|
| root      | The path to install roslin core, or an existing installation of roslin core |
| mongo      | All the information needed to connect to the mongo database |

Here is a table containing the description of important keys in `config.variant.yaml`:

| Key       | Description       |
| :------------- |:-------------|
| root      | The path to install roslin pipeline |
| binding.extra      | All the paths in the host system that needs to be mounted |
| env      | Envirornment variables to set before running the pipeline |
| dependencies.singularity      | Location of singularity binary files |
| build.installCore     | Option to either install core or use an existing installation |
| test.tempDir     | Path to test tempdir |
| test.runArgs     | Path to test run arguments |

Here is how to use the `source` key under `dependencies` in `config.variant.yaml`:

| Type       | Example       | Description |  Dependency Supported |
| :------------- |:-------------| :-------------| :-------------|
| path      | path:/usr/local/bin/singularity | Path to binary or source files | singularity, cmo, toil
| module      | module:singularity | Module name with the version key representing the module version | singularity
| github      | github:https://github.com/dataBiosphere/toil | Github repo with the version key representing the branch/tag | toil, cmo

For installation, simply run this script. Make sure it has internet access:
```
./build-pipeline.sh
```

After installation is completed you should see a message like this:
```
 ______     ______     ______     __         __     __   __
/\  == \   /\  __ \   /\  ___\   /\ \       /\ \   /\ "-.\ \
\ \  __<   \ \ \/\ \  \ \___  \  \ \ \____  \ \ \  \ \ \-.  \
 \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \_\  \ \_\\"\_\
  \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/   \/_/ \/_/
 ______   __     ______   ______     __         __     __   __     ______
/\  == \ /\ \   /\  == \ /\  ___\   /\ \       /\ \   /\ "-.\ \   /\  ___\
\ \  _-/ \ \ \  \ \  _-/ \ \  __\   \ \ \____  \ \ \  \ \ \-.  \  \ \  __\
 \ \_\    \ \_\  \ \_\    \ \_____\  \ \_____\  \ \_\  \ \_\\"\_\  \ \_____\
  \/_/     \/_/   \/_/     \/_____/   \/_____/   \/_/   \/_/ \/_/   \/_____/

Roslin Pipeline

Your workspace: /home/vagrant/roslin-pipelines/variant/2.6.0/workspace/vagrant-3.10

Add the following line to your .profile or .bashrc if not already added:

source /home/vagrant/roslin-core/2.1.2/config/settings.sh
```

This message has two important pieces of information:
1. The location of your workspace in the pipeline
2. The settings.sh file that sets your env to operate the pipeline

Make sure to source the `settings.sh` in your `~/.bashrc` or some other appropriate startup dotfile.

## Test an example

Source the `settings.sh`, enter a folder with sample data, and run the bash wrapper around `roslin_request_to_yaml.py` and `roslin_submit.py`:
```
source [your settings.sh file path]
cd [your workspace path]/examples/SampleWorkflow
./run-example.sh
```

## Add a user

If another user wants to run your deployment of Roslin, they can setup their own workspace by running:
```
source [your settings.sh file path]
roslin_workspace_init.py --name [your pipeline name] --version [your pipeline version]
```
