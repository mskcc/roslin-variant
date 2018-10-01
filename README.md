# Roslin-variants

Table of Contents:
    
1. From Build to Deploy
1. Adding New Tool to Pipeline
1. Running Pipeline
    1. Prerequisites
    1. Setting Up Workspace

## From Build to Deploy

![/docs/prism-build-to-deploy.png](/docs/prism-build-to-deploy.png)

### Step 1

- [Set Up Virtual Machine](./docs/build-to-deploy/set-up-vm.md)

### Step 2 and 3

- [Build Everything](./docs/build-to-deploy/build-everything.md)

### Step 4

- [Create Setup Package](./docs/build-to-deploy/create-setup-package.md)

### Step 5

- [Deploy](./docs/build-to-deploy/deploy.md)

## Adding New Tool to Pipeline

- [Build Container Image](./docs/build-to-deploy/build-container-image.md)
- [Build CWL Wrapper](./docs/build-to-deploy/build-cwl-wrappers.md)

## Running Pipeline

### Prerequisites

To run the pipeline you need:

- Python 2.7.x
- Node.js 6.1.0
- [Singularity 2.2.1](http://singularity.lbl.gov/release-2-2-1)
- Toil
- [cmo](https://github.com/mskcc/cmo)

Luna already fulfills these requirements.

### Setting Up Workspace

Please refer to [this document](./docs/workspace/setup.md).
