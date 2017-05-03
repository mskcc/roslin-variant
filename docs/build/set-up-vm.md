# Set Up VM

This document covers Step 1:

```
1) Set Up VM --> 2) Build --> 3) Move Artifacts --> 4) Create Setup Package --> 5) Deploy
```

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

Make sure that the bind points defined above must be defined in `/build/settings-container.sh` as well. Note that, unlike the above, here each path is separated by a single space character. The directories specified in this file will be automatically created duruing the image creation process. This is necessary to make the images compatible with environments where Overlay FS is not supported. For more information about this, please refer to the [Bind Paths / File Sharing](http://singularity.lbl.gov/docs-mount) section of the Singularity's User Guide.

```bash
export SINGULARITY_BIND_POINTS="/ifs/work/chunj/prism-proto/ifs /ifs/work/chunj/prism-proto/prism /scratch"
```

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
$ python --version
$ singularity --version
$ docker --version
$ cat /usr/local/bin/cmo-gxargparse/cmo/cmo/_version.py
```
