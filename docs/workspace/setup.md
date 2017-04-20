# Setting Up Prism Workspace

*Table of Contents*

1. Supported MSKCC HPC Clusters
1. Prerequisites
1. Configuring Workspace
1. Running Examples
1. Running Module 1 with Your Own Data

## Supported MSKCC HPC Clusters

This has been tested on the MSKCC Luna cluster (http://hpc.mskcc.org/index.php/hpc-systems-old/bioinformatics-hpc/the-luna-cluster/)

## Prerequisites

### For users of the Luna cluster at MSKCC CMO

Log in to Luna and check if you have access to Node.js REPL (shell):

```bash
$ node
>
```

If not, add the following to your profile (`~/.profile` or `~/.bash_profile`):

```bash
export PATH="$PATH:/opt/common/CentOS_6-dev/nodejs/node-v6.10.1/bin/"
export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.3/lib64:$LD_LIBRARY_PATH
```

Log out and log back in or execute `source ~/.profile`.

### For external users

Follow [this instructions](./prerequisites.md) to install Node.js.

## Configuring Workspace

Log in to one of the MSKCC HPC clusters.

Change to the setup directory:

```bash
$ cd /ifs/work/chunj/prism-proto/prism/bin/setup
```

Run the following command. Make sure to replace `chunj` with your own login name:

```bash
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
chunj
└── examples
    ├── bsub-of-prism-runner
    ├── cmo-abra
    ├── cmo-bwa-mem
    ├── cmo-gatk.FindCoveredIntervals
    ├── cmo-gatk.SomaticIndelDetector
    ├── cmo-list2bed
    ├── cmo-mutect
    ├── cmo-picard.AddOrReplaceReadGroups
    ├── cmo-picard.MarkDuplicates
    ├── cmo-pindel
    ├── cmo-trimgalore
    ├── cmo-vardict
    ├── data
    ├── env
    ├── module-1
    ├── module-2
    ├── module-3
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

|   JOBID | STAT   | JOB_NAME                                | MAX_REQ_PROC   | EXEC_HOST   |
|---------+--------+-----------------------------------------+----------------+-------------|
| 9367614 | DONE   | CWLWorkflow                             | -              | u35         |
| 9367615 | DONE   | cmo_trimgalore                          | 2              | 2*u35       |
| 9367618 | DONE   | cmo_bwa_mem                             | 5              | 5*u35       |
| 9367624 | DONE   | cmo_picard_--cmd_AddOrReplaceReadGroups | 2              | 2*u35       |
| 9367629 | DONE   | cmo_picard_--cmd_MarkDuplicates         | 2              | 2*u35       |
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
  path: .../data/fastq/P1_R1.fastq.gz
fastq2:
  class: File
  path: .../data/fastq/P1_R2.fastq.gz

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

tmp_dir: $TMPDIR
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

The current supported workflows that you can specify with `-w` is as follows:

```
cmo-abra/0.92/cmo-abra.cwl
cmo-bwa-mem/0.7.12/cmo-bwa-mem.cwl
cmo-bwa-mem/0.7.15/cmo-bwa-mem.cwl
cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
cmo-gatk.BaseRecalibrator/3.3-0/cmo-gatk.BaseRecalibrator.cwl
cmo-gatk.FindCoveredIntervals/3.3-0/cmo-gatk.FindCoveredIntervals.cwl
cmo-gatk.PrintReads/3.3-0/cmo-gatk.PrintReads.cwl
cmo-gatk.SomaticIndelDetector/2.3-9/cmo-gatk.SomaticIndelDetector.cwl
cmo-list2bed/1.0.0/cmo-list2bed.cwl
cmo-mutect/1.1.4/cmo-mutect.cwl
cmo-picard.AddOrReplaceReadGroups/1.129/cmo-picard.AddOrReplaceReadGroups.cwl
cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl
cmo-picard.FixMateInformation/1.96/cmo-picard.FixMateInformation.cwl
cmo-picard.MarkDuplicates/1.129/cmo-picard.MarkDuplicates.cwl
cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl
cmo-pindel/0.2.5a7/cmo-pindel.cwl
cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
cmo-trimgalore/0.4.3/cmo-trimgalore.cwl
cmo-vardict/1.4.6/cmo-vardict.cwl
module-1.cwl
module-2.cwl
module-3.cwl
samtools/1.3.1/samtools-sam2bam.cwl
```
