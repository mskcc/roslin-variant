# Set Up Virtual Machine

This document covers Step 1:

![/docs/prism-build-to-deploy.png](/docs/prism-build-to-deploy.png)

## Prerequisites

The versions mentioned here are the ones that are tested. This does not necessarily mean that higher versions would automatically work.

- [Vagrant 1.9.0](https://www.vagrantup.com/downloads.html)
- [Decent version of Git](https://git-scm.com/downloads)

## Download Source Code

```bash
$ git clone https://github.com/mskcc/prism-pipeline.git
```

```
$ tree prism-pipeline -L 2 -d
.
├── build
│   ├── containers
│   ├── cwl-wrappers
│   └── scripts
├── cloud
│   └── aws
├── docs
│   ├── build
│   ├── dev
│   └── workspace
├── setup
│   ├── bin
│   ├── cwl-wrappers
│   ├── data
│   ├── schemas
│   ├── scripts
│   └── tools
├── test
│   ├── helpers
│   ├── mock
│   └── outputs
└── vm
```

## Settings

### /setup/settings.sh

Configure `/setup/settings.sh`. Below is what's already configured for the Luna environment. No need to change unless you know what you're doing.

```bash
PRISM_ROOT="/ifs/work/chunj/prism-proto"

#--> the following paths will be supplied to singularity as bind points

# binaries, executables, scripts
export PRISM_BIN_PATH="${PRISM_ROOT}/prism"

# reference data (e.g. genome assemblies)
export PRISM_DATA_PATH="${PRISM_ROOT}/ifs"

# other paths that we'd like to bind (space separated)
export PRISM_EXTRA_BIND_PATH="/scratch"

#<--

# input files to pipeline (e.g. fastq files)
export PRISM_INPUT_PATH="${PRISM_ROOT}/ifs/prism/inputs"

# path to singularity executable
# singularity is expected to be found at the same location regardless of the nodes you're on
# override this if you want to test a different version of singularity.
export PRISM_SINGULARITY_PATH="/usr/bin/singularity"
```

### /build/settings-container.sh

Make sure that the bind points defined in `/setup/settings.sh` must be also defined in `/build/settings-container.sh`.

```bash
export SINGULARITY_BIND_POINTS="/ifs/work/chunj/prism-proto/ifs /ifs/work/chunj/prism-proto/prism /scratch"
```

Note that each path is separated by a single space character. The directories specified in this file will be automatically created inside the container duruing the image creation process. This is necessary to make the images compatible with runtime environments where Overlay FS is not supported.

For more information about this, please refer to the [Bind Paths / File Sharing](http://singularity.lbl.gov/docs-mount) section of the Singularity's User Guide.

## Create Build Envrionment

Everything related to building container images and generating CWL wrappers will be done inside a virtual machine. Thus, you need to spawn a virtual machine first using Vagrant.

The following command will spawn a virtual machine and automatically install everything that is needed to build container images and generate CWL wrappers (such as Docker, Singularity, cmo, gxargparse, and etc)

```bash
$ vagrant up
```

SSH into the vagrant box:

```bash
$ vagrant ssh
```

Now you're inside the virtual machine. Try the following commands to see if everything is correctly installed:

```bash
$ /vagrant/vm/check-versions.sh
python : Python 2.7.12
pip : pip 8.1.1 from /usr/lib/python2.7/dist-packages (python 2.7)
docker : Docker version 1.13.1, build 092cba3
singularity : 2.2.1
cmo : 1.0.5
```
