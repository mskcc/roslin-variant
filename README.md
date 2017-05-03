# prism-pipeline

Table of Contents:

1. Prerequisites
1. From Build to Deploy
1. Setting Up Workspace

## Prerequisites

To run the pipeline you need:

- Python 2.7.x
- Node.js 6.1.0
- [Singularity 2.2.1](http://singularity.lbl.gov/release-2-2-1)
- cwltoil
- [cmo](https://github.com/mskcc/cmo)


## From Build to Deploy

![/docs/prism-build-to-deploy.png](/docs/prism-build-to-deploy.png)

### Step 1

- [Set Up Virtual Machine](./docs/build-to-deploy/set-up-vm.md)

### Step 2 and 3

- [Build Everything](./docs/build-to-deploy/build-everything.md)
- [Build Container Image](./docs/build-to-deploy/build-container-image.md)
- [Build CWL Wrapper](./docs/build-to-deploy/build-cwl-wrappers.md)

### Step 4

- [Create Setup Package](./docs/build-to-deploy/create-setup-package.md)

### Step 5

- [Deploy](./docs/build-to-deploy/deploy.md)

## Setting Up Workspace

Please refer to [this document](./docs/workspace/setup.md). 