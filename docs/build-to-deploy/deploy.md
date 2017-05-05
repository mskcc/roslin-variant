# Deploy

This document covers Step 5:

![/docs/prism-build-to-deploy.png](/docs/prism-build-to-deploy.png)

Table of Contents:

1. Luna
1. Amazon Web Services
1. Local Virtual Machine

## Luna

Please note that the current setup script supports only a single version of Prism be installed on Luna.

You can either use [Fabric](http://www.fabfile.org/) or do it manually. 

### Fabric

Make sure to use your own private key and UNIX account.

```bash
$ fab -i ~/.ssh/id_rsa -u chunj -H u36.cbio.mskcc.org rsync_luna
```

### Manual

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

## Amazon Web Services

The most up-to-date instructions can be found [here](../cloud/aws/README.md).

## ~~Local Virtual Machine~~ (OUTDATED)

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
