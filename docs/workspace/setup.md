# Setting Up Prism Workspace

*Table of Contents*

1. Prerequisites
1. Configuring Workspace
1. Running Examples
1. Running Module 1 with Your Own Data

## Prerequisites

First, log in to `selene.mskcc.org` and check if you have access to Node.js REPL (shell):

```bash
$ node
>
```

If not, follow [this instructions to install it](./prerequisites.md).

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

### 1. Job Submission

Go to your workspace:

```bash
$ cd $PRISM_INPUT_PATH/chunj
```

You will find the `examples` directory:

```bash
chunj/
└── examples
   ├── cmo-bwa-mem
   ├── cmo-picard.AddOrReplaceReadGroups
   ├── cmo-picard.MarkDuplicates
   ├── cmo-trimgalore
   ├── fastq
   ├── module-1
   └── samtools-sam2bam
```

For example, you can run Module 1 by:

```bash
$ cd examples/module-1
$ ./run-example.sh
```

Each job will be given a unique job UUID. And the output of the job will be placed in the `./outputs` directory by default unless you override it. 

### 2. Job Status

To see the status of the job while it's running, open another terminal, and run the following command. This must be run from the directory where you ran the job or use `-o` to specify the job output directory:

```bash
$ cd $PRISM_INPUT_PATH/chunj/examples/module-1
$ prism-job-status.sh
```

### 3. Archiving

Run the following command to archive the job output and log files once the job is completed. This must be run from the directory where you ran the job or use `-o` to specify the job output directory:

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

Here are some of the parameters you can specify for `prism-runner.sh`:

- `-w` : Workflow filename (*.cwl)
- `-i` : Input filename (*.yaml)
- `-b` : Batch system ("singleMachine", "lsf", "mesos")
- `-o` : Output directory (default=./outputs)
- `-r` : Restart the workflow with the given job UUID

The current supported workflow that you can specify with `-w` is as follows:

- module-1.cwl
- cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
- cmo-trimgalore/0.4.3/cmo-trimgalore.cwl
- cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
- cmo-bwa-mem/0.7.12/cmo-bwa-mem.cwl
- cmo-bwa-mem/0.7.15/cmo-bwa-mem.cwl
- cmo-picard.AddOrReplaceReadGroups/1.129/cmo-picard.AddOrReplaceReadGroups.cwl
- cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl
- cmo-picard.MarkDuplicates/1.129/cmo-picard.MarkDuplicates.cwl
- cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl
- samtools/1.3.1/samtools-sam2bam.cwl
