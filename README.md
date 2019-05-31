# Roslin-variant

> Roslin-variant is a reproducible and reusable workflow for Cancer Genomic Sequencing Analysis

## Prerequisites

To run the pipeline you need:

- Python 2.7.x
- [Singularity 3.0.3](https://github.com/sylabs/singularity/releases/tag/v3.0.3)
- [Toil 3.18](https://github.com/DataBiosphere/toil/releases/tag/releases%2F3.18.0)
- [cmo 1.9.10](https://github.com/mskcc/cmo/releases/tag/1.9.10)

## Installation

#### Download

###### Clone the repo and checkout

```
git clone https://github.com/mskcc/roslin-variant.git
git checkout 2.5.x
```

###### Update the core

```
git submodule init
git submodule update
```

#### Configure

###### Configure the core

You would need to edit the core config file located in: `core/config.core.yaml`

Here is a table containing the description of important keys for the core config.

| Key       | Description       |
| :------------- |:-------------|
| root      | The path to install roslin core, or an existing installation of roslin core |
| mongo      | All the information needed to connect to the mongo database |

###### Configure the pipeline

You would need to edit the core config file located in: `config.variant.yaml`

Here is a table containing the description of important keys for the variant config.

| Key       | Description       |
| :------------- |:-------------|
| root      | The path to install roslin pipeline |
| binding.extra      | All the paths in the host system that needs to be mounted |
| env      | Envirornment variables to set before running the pipeline |
| dependencies      | Path to all dependencies, ensure that the install-path is configured correctly |
| build.installCore     | Option to either install core or use an existing installation |
| test.tempDir     | Path to test tempdir |
| test.runArgs     | Path to test run arguments |

#### Install

For installation, you would need to have Internet access

```
./build-pipeline.sh
```

#### Run an example

###### Load the settings
```
source [roslin_core_path]/2.1.0/config/settings.sh
source [roslin_core_path]/2.1.0/config/variant/2.5.0/settings.sh

```

Test projects for all the workflows are located in `$ROSLIN_EXAMPLE_PATH`

```
cd $ROSLIN_EXAMPLE_PATH/SampleWorkflow
./run-example.sh
```

---

Please report all bugs [ here ](https://github.com/mskcc/roslin-variant/issues)
