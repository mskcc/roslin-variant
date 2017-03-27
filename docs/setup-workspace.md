# Set Up Prism Workspace

Table of Contents

1. Prerequisites
    1. Node.js
    1. csvkit
1. Configuring Prism Workspace
1. Running Examples
1. Running Module 1 with Your Own Data

## Prerequisites

### 1. Node.js

This step is necessary until sysadmin installs Node.js across all cluster nodes.

Log in to `selene.mskcc.org` and run the following command:

```bash
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
```

Add the following lines to your profile (`~/.profile` or `~/.bash_profile`)

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```

Log out and log back in. At this point, executing `command -v nvm` should return `nvm`.

Run the following:

```bash
$ nvm install 6.10
$ nvm use 6.10
$ nvm alias default node
```

Execute `node --version`, and you are all set if you see `v6.10.0`.

### 2. csvkit

This is optional. This will give you an pretty output for the job status.

Log in to `selene.mskcc.org` and run the following command:

```bash
$ pip install csvkit --user
```

If `~/.local/bin` is not already included in `PATH`, add the following line to your profile (`~/.profile` or `~/.bash_profile`) 

```bash
PATH="$PATH:~/.local/bin"
```

## Configuring Prism Workspace

Log in to `selene.mskcc.org`.

Run the following command. Make sure to replace `chunj` with your own login name:

```bash
$ cd /ifs/work/chunj/prism-proto/prism/bin/setup
$ ./prism-init.sh -u chunj
```


Log out and log back in or execute `source ~/.profile`.

You're all set.

## Running Examples

Make sure to replace `chunj` with your own login name.

Go to your workspace:

```bash
$ cd $PRISM_INPUT_PATH/chunj
```

You will find the `examples` directory.

Run Module 1:

```bash
$ cd examples/module-1
$ ./run-example.sh
```

To see the status of the job, open another terminal, and run the following command. This must be run from where you ran the job or use `-o` to specify the job output directory:

```bash
$ cd $PRISM_INPUT_PATH/chunj/examples/module-1
$ prism-job-status.sh
```

Run the following command to archive the job output and log files once the job is completed. This must be run from where you ran the job or use `-o` to specify the job output directory:

```bash
$ cd $PRISM_INPUT_PATH/chunj/examples/module-1
$ prism-job-archive.sh
```

## Running Module 1 with Your Own Data

Make a new directory.

Create a new `inputs.yaml` something like below and make necessary changes such as setting paths to your fastq files and etc.

```yaml
adapter: "AGATCGGAAGAGCACACGTCTGAACTCCAGTCACATGAGCATCTCGTATGCCGTCTTCTGCTTG"
adapter2: "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT"
fastq1:
  class: File
  path: ../fastq/P1_R1.fastq.gz
fastq2:
  class: File
  path: ../fastq/P1_R2.fastq.gz

genome: "GRCh37"
bwa_output: P1.bam

add_rg_LB: "5"
add_rg_PL: "Illumina"
add_rg_ID: "P-0000377"
add_rg_PU: "bc26"
add_rg_SM: "P-0000377-T02-IM3"
add_rg_CN: "MSKCC"
add_rg_output: "P-0000377-T02-IM3_ARRDRG.bam"

md_output: "P-0000377-T02-IM3_ARRDRG_MD.bam"
md_metrics_output: "P-0000377-T02-IM3_ARRDRG_MD.metrics"

create_index: True

tmp_dir: "/ifs/work/chunj/prism-proto/prism/tmp"
```

Run the following command:

```bash
$ prism-runner.sh \
    -w module-1.cwl \
    -i inputs.yaml \
    -b lsf
```