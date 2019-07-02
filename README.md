# Roslin-variant

> Roslin-variant is a reproducible and reusable workflow for Cancer Genomic Sequencing Analysis

## Prerequisites

To run the pipeline you need:

- Python 2.7.x ( with virtualenv )
- [Singularity 3.1.1+](https://github.com/sylabs/singularity/releases/tag/v3.1.1)

## Installation

#### Download

###### Clone the repo and checkout

```
git clone https://github.com/mskcc/roslin-variant.git
cd roslin-variant
git checkout 2.5.x
```

###### Update the core

```
git submodule init
git submodule update
```

#### Configure

##### Configure the core

You would need to edit the core config file located in: `core/config.core.yaml`

Here is a table containing the description of important keys for the core config.

| Key       | Description       |
| :------------- |:-------------|
| root      | The path to install roslin core, or an existing installation of roslin core |
| mongo      | All the information needed to connect to the mongo database |

##### Configure the pipeline

###### For MSKCC users on the the Juno cluster:

Use the example config: [sample-juno-config.yaml](sample-juno-config.yaml)

```
cp sample-juno-config.yaml config.variant.yaml
```

1. Add the root with the path where you want tot install the pipeline
2. Modify TOIL_LSF_ARGS within both root and test env's

You can used TOIL_LSF_ARGS to run your jobs under a SLA. For example:

```
TOIL_LSF_ARGS: '-S 1 -sla CMOPI'
```

###### For other users:

You would need to edit the pipeline config file located in: `config.variant.yaml`

Here is a table containing the description of important keys for the variant config.

| Key       | Description       |
| :------------- |:-------------|
| root      | The path to install roslin pipeline |
| binding.extra      | All the paths in the host system that needs to be mounted |
| env      | Envirornment variables to set before running the pipeline |
| dependencies.singularity      | Location of singularity binary files |
| build.installCore     | Option to either install core or use an existing installation |
| test.tempDir     | Path to test tempdir |
| test.runArgs     | Path to test run arguments |

Here is a table describing how to use the `source` field for dependencies

| Type       | Example       | Description |  Dependency Supported |
| :------------- |:-------------| :-------------| :-------------|
| path      | path:/usr/local/bin/singularity | Path to binary or source files | singularity, cmo, toil
| module      | module:singularity | Module name with the version key representing the module version | singularity
| github      | github:https://github.com/dataBiosphere/toil | Github repo with the version key representing the branch/tag | toil, cmo

#### Install

For installation, you would need to have Internet access

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

Your workspace: /juno/work/pi/nikhil/roslin-workspace/variant/2.5.0/workspace/nikhil-3.10

Add the following line to your .profile or .bashrc if not already added:

source /juno/work/pi/nikhil/roslin-workspace/roslin-core/2.1.0/config/settings.sh
```
This message has two important pieces of information:
1. The settings.sh file that needs to be sourced before running the pipeline
2. The location of your workspace in the pipeline.

Make sure to add the settings.sh to your .bashrc or any startup script

#### Run an example

To run an example you need to load the settings and enter the example directory

```
source [your settings.sh file path]
cd [your workspace path]/examples

```

Now we can run an example workflow

```
cd SampleWorkflow
./run-example.sh
```

#### User setup

If another user wants to run your pipeline, they can setup their workspace by running:

```
source [your settings.sh file path]
roslin_workspace_init.py --name [your pipeline name] --version [your pipeline version]
```

---

Please report all bugs [ here ](https://github.com/mskcc/roslin-variant/issues)
