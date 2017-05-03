# Deploy

This document covers Step 5:

```
1) Set Up VM --> 2) Build --> 3) Move Artifacts --> 4) Create Setup Package --> 5) Deploy
```

Table of Contents:

1. Local Virtual Machine
1. Luna
1. Amazon Web Services

## Installation

### Luna

You can either use `Fabric` or do it manually

#### Fabric

Make sure to use your own private key and UNIX account.

```bash
$ fab -i ~/.ssh/id_rsa -u chunj -H u36.cbio.mskcc.org rsync_luna
```

#### Manual

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

### ~~Amazon Web Services~~ (OUTDAˇED)

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
$ sudo mkdir -p /ifs && sudo chmod a+w /ifs
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

Set singularity path in `settings.sh` to `/usr/local/bin/singularity`.

Log out and log back in.

### ~~Local Virtual Machine~~ (OUTDAˇED)

Get genome assemblies files and place them under `./setup/data/assemblies`.

Upload the installation package to the VM (this uses `rsync`):

```bash
$ sync-to-vm.sh -p 7777 -u chunj
```

Log in to the virtual machine.

Create a directory where Prism will be installed:

```bash
$ sudo mkdir -p /ifs && sudo chmod a+w /ifs
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
