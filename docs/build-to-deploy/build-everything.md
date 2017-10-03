# Building Everything

This document covers Step 2 and 3:

![/docs/prism-build-to-deploy.png](/docs/prism-build-to-deploy.png)

## Build Container Images and CWL Wrappers

Inside the virtual machine, run the following command to bulid *all* the necessary container images as well as the CWL wrappers.

```bash
$ cd /vagrant/build/scripts/
$ ./build-all.sh
```

Note that this will not push the generated docker images to Docker Hub. If you do want to push, run with the `-p` parameter.

## Move Artifacts

The following command will gather all the created container images as well as the CWL wrappers and place them in the `/setup` directory.

```bash
$ ./move-all-artifacts-to-setup.sh
```
