# Set Up Prism Workspace

## Configure Workspace

Log in to `selene.mskcc.org`.

```bash
cd /ifs/work/chunj/prism-proto/prism/bin/setup
./prism-init.sh -u socci
```

Log out and log back in or execute `source ~/.profile`.

You're ready.

## Running Examples

Go to your workspace:

```bash
cd $PRISM_INPUT_PATH/socci
```

Run Module 1:

```bash
prism-runner.sh \
    -w module-1.cwl \
    -i inputs-module-1.yaml \
    -b lsf
```
