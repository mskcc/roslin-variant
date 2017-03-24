# prism-pipeline

Table of Contents:

1. Prerequisites
1. Preparation
1. Building Everything
1. Building Tools Individually
    1. Container Images
    1. CWL Wrappers
1. Creating Installation Package
1. Installation
    1. Local Virtual Machine
    1. Luna
    1. Amazon Web Services

## Prerequisites

The versions mentioned here are the ones that are tested. This does not necessarily mean that higher versions would automatically work.

- For Building Pipelines
    - [Vagrant 1.9.0](https://www.vagrantup.com/downloads.html)
        
- For Running Pipelines
    - Python 2.7.x
    - Node.js 6.1.0
    - [Singularity 2.2.1](http://singularity.lbl.gov/release-2-2-1)
    - cwltoil
    - [cmo](https://github.com/mskcc/cmo)

## Preparation

Make sure that the bind points defined in the following directories must match each other.

- `/setup/settings.sh`
- `/build/settings-container.sh`

## Building Everything

Bring up the vagrant box:

```bash
$ vagrant up
$ vagrant ssh
```

Run the following command to bulid all the necessary container images as well as the CWL wrappers:

```bash
$ cd /vagrant/build/scripts/
$ ./build-all.sh
```

The following command will gather all the created container images as well as the CWL wrappers and place them in the `setup` directory.

```bash
$ ./move-all-artifacts-to-setup.sh
```

## Building Tools Individually

### Container Images

![/docs/image-build-process.png](./docs/image-build-process.png)

```bash
$ cd /vagrant/build/scripts/
$ ./build-images.sh
```

The `-t` parameter allows you to build a specific tool image:

```bash
$ ./build-images.sh -t bwa-mem:0.7.5a
```

The following command will gather all the created container images and place them in the `setup` directory.

```bash
$ ./move-container-artifacts-to-setup.sh
```

### CWL Wrappers

```bash
$ cd /vagrant/build/scripts/
$ ./build-cwl.sh
```


The `-t` parameter allows you to build a specific CWL wrapper:

```bash
$ ./build-cwl.sh -t bwa-mem:0.7.5a:cmo_bwa_mem
```

The following command will gather all the generated cwl files and place them in the `setup` directory. You must run this from inside the vagrant box.

```bash
$ ./move-cwl-artifacts-to-setup.sh
```

## Creating Installation Package

Exit out from the vagrant box and run the following command. This will create `prism-v1.0.0.tgz`.

```bash
$ ./compress.sh
```

## Installation

### Local Virtual Machine

Get genome assemblies files and place them under `./setup/data/assemblies`.

Upload the installation package to the VM (this uses `rsync`):

```bash
$ sync-to-vm.sh -p 7777 -u chunj
```

Log in to the virtual machine.

Create a directory where Prism will be installed:

```bash
$ sudo mkdir -p /scratch && sudo chmod a+w /scratch
```

Install cmo wrapper:

```bash
$ cd /tmp/prism-setup/scripts
$ ./install-cmo.sh
```

Start installation:

```bash
$ ./install-production.sh -l
$ ./configure-reference-data.sh -l local
``` 

Log out and log back in.

### Luna (u36)

If you have `Fabric` on your machine, just run `fab -i [your-private-key] install`, otherwise follow the instructions below.

Upload the installation package to Luna:

```bash
$ scp prism-v1.0.0.tgz chunj@u36.cbio.mskcc.org:/home/chunj
```

Log in to `u36.cbio.mskcc.org`.

Uncompress the installation package:

```bash
$ mkdir prism-setup-v1.0.0
$ tar xvzf prism-v1.0.0.tgz -C prism-setup-v1.0.0
```

Start installation:

```bash
$ cd prism-setup-v1.0.0/setup/scripts
$ ./install-production.sh -l
$ ./configure-reference-data.sh -l ifs
```

Log out and log back in.

### Amazon Web Services

Bring up an AWS EC2 instance (minimum `t2.large` with 50GB disk) using the AMI `ami-2cc4643a`. This AMI is not currently exposed to public. Add Full S3 Access role to EC2 being spawned.

Upload the installation package to AWS EC2.

```bash
$ ./upload-to-ec2.sh -k ~/mskcc-chunj.pem -h ec2-w-x-y-z.compute-1.amazonaws.com
```

Log in to EC2:

```bash
$ ssh -i "~/mskcc-chunj.pem" ubuntu@ec2-w-x-y-z.compute-1.amazonaws.com
```

Create a directory where Prism will be installed:

```bash
$ sudo mkdir -p /scratch && sudo chmod a+w /scratch
```

Uncompress the installation package:

```bash
$ cd /tmp
$ tar xvzf prism-v1.0.0.tgz
```

Install cmo wrapper:

```bash
$ cd /tmp/setup/scripts/
$ ./install-cmo.sh
```

Start installation:

```bash
$ ./install-production.sh -l
$ ./configure-reference-data.sh -l s3
```

Log out and log back in.


## Adding a New Tool

Please refer to [this document](./docs/adding-new-tool.md)
