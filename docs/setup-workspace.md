# Set Up Prism Workspace

## Prerequisites

### 1. Node.JS

Log in to `selene.mskcc.org` and run the following command:

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
```

Add the following lines to your profile (`~/.profile` or `~/.bash_profile`)

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```

Log out and log back in.

Run the following:

```bash
nvm install 6.10
nvm use 6.10
nvm alias default node
```

### 2. csvkit

This is optional. This will give you an pretty output for the job status.

Log in to `selene.mskcc.org` and run the following command:

```bash
pip install csvkit --user
```

If `~/.local/bin` is not already included in `PATH`, add the following line to your profile (`~/.profile` or `~/.bash_profile`) 

```bash
PATH="$PATH:~/.local/bin"
```

## Configuring Workspace

Log in to `selene.mskcc.org`.

Run the following command. Make sure to replace `chunj` with your own HPC account ID:

```bash
cd /ifs/work/chunj/prism-proto/prism/bin/setup
./prism-init.sh -u chunj
```


Log out and log back in or execute `source ~/.profile`.

You're ready.

## Running Examples

Go to your workspace:

```bash
cd $PRISM_INPUT_PATH/chunj
```

You will find the `examples` directory.

Run Module 1:

```bash
cd examples/module-1
./run-example.sh
```

To see the status of the job, open another terminal, and run the following command from where you run the job:

```bash
cd $PRISM_INPUT_PATH/socci/examples/module-1
prism-job-status.sh
```

Archive the job output and log files:

```bash
cd $PRISM_INPUT_PATH/socci/examples/module-1
prism-job-status.sh
```

```bash
prism-runner.sh \
    -w module-1.cwl \
    -i inputs-module-1.yaml \
    -b lsf
```
