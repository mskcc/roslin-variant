# Unit Test

## Run Test


### Procedure

1. Run a specific workflow or a single tool on Selene.
1. Collect output metadata (e.g. name of the bam files generated, location of the bam files)
1. Run `nosetests` to check if output files are correctly generated (e.g. expected file name, file size > 0, and etc.)

### How

On Selene:

```bash
$ cd $PRISM_INPUT_PATH/$USER/examples/unit-test
```

The following command will run all the examples in your workspace directory, collect the metadata about outputs, and place them under the `./outputs/` directory.

```bash
$ ./collect-outputs.sh
```

Outputs will be placed under `./outputs/` of each tool's example directory. If this directory is not empty, you might want to clean up. The following command will delete `examples/**/outputs`.

```bash
$ ./clean-outputs.sh
```

If you want to run a specific example, you can supply the example directory name with `-t`:

```bash
$ ./collect-outputs.sh -t module-4
```

The `-z` parameter will display all the example directory names you can supply with `-t`:

```bash
$ ./collect-outputs.sh -z
module-1
module-1-2-3
cmo-bwa-mem
...
..
.
```

Once the output collection mentioned in the above is done, you can run `nosetests`:

```bash
$ nosetests
```

## Script Test

### Purpose

- Test if the following bash scripts function correctly
  - `prism-runner.sh`
  - `sing.sh`
  - `sing-java.sh`

### How

On your local workstation, go to the directory where you git cloned prism-pipeline, and SSH into the Vagrant build box:

```bash
$ vagrant ssh
```

Once you get into the Vagrant box, execute the following command to install test helpers. You only need to do this for once:

```bash
$ cd /vagrant/test
$ ./install-test-helpers.sh
```

Test `prism-runner.sh`:

```bash
$ cd /vagrant/test
$ bats prism-runner.bats
 ✓ should have prism-runner.sh
 ✓ should abort if all the necessary env vars are not configured
 ✓ should abort if PRISM_BIN_PATH is not configured
 ✓ should abort if PRISM_DATA_PATH is not configured
 ✓ should abort if PRISM_EXTRA_BIND_PATH is not configured
 ✓ should abort if PRISM_INPUT_PATH is not configured
 ✓ should abort if PRISM_SINGULARITY_PATH is not configured
 ✓ should abort if unable to find Singularity at PRISM_SINGULARITY_PATH
 ✓ should skip checking Singularity existence if on one of those leader nodes
 ✓ should abort if workflow or input filename is not supplied
 ✓ should abort if input file doesn't exit
 ✓ should abort if batch system is not specified with -b
 ✓ should abort if unknown batch system is supplied via -b
 ✓ should abort if mesos is selected for batch system
 ✓ should abort if output directory already exists
 ✓ should output job UUID at the beginning and the end
 ✓ should correctly construct the parameters when calling cwltoil
 ✓ should correctly construct the parameters when calling cwltoil for lsf
 ✓ should correctly construct the parameters when calling cwltoil for singleMachine
 ✓ should correctly handle -o (output directory) parameter when calling cwltoil
 ✓ should correctly handle -v (pipeline version) parameter when calling cwltoil
 ✓ should set CMO_RESOURCE_CONFIG correctly before run, unset after run
 ✓ should correctly handle -r (restart) parameter when calling cwltoil
 ✓ should set TOIL_LSF_PROJECT correctly before run, unset after run
 ✓ should correctly handle -p (CMO project ID) parameter
 ✓ should correctly handle -j (job UUID) parameter

26 tests, 0 failures
```

Test `sing.sh`:

```bash
$ bats sing.bats
 ✓ should have sing.sh
 ✓ should be able to run singularity
 ✓ should abort if all the necessary env vars are not configured
 ✓ should abort if PRISM_SINGULARITY_PATH is not configured
 ✓ should abort if PRISM_DATA_PATH is not configured
 ✓ should abort if PRISM_BIN_PATH is not configured
 ✓ should abort if PRISM_EXTRA_BIND_PATH is not configured
 ✓ should abort if the two required parameters are not supplied
 ✓ should run the tool image and display 'Hello, World!'
 ✓ should properly bind extra paths defined

10 tests, 0 failures
```

Test `sing-java.sh`:

```bash
$ bats sing-java.bats
 ✓ should have sing.sh
 ✓ should have sing-java.sh
 ✓ should properly reconstruct the command
 ✓ should properly construct the sing call for picard 1.129
 ✓ should properly construct the sing call for picard 1.96
 ✓ should properly construct the sing call for abra 0.92
 ✓ should properly construct the sing call for mutect 1.1.4

7 tests, 0 failures
```
