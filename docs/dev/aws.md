# Amazon Web Services

Use Packer to build an AMI first.

## Single Machine Test

Launch r4.2xlarge (us-east-1b):

- 8 vCPU
- 61 GB RAM
- EBS-Only (no need to mount so easy to set up)
- Price (as of 2017-04-27)
    - $0.665 per hour (on-demand)
    - Avg $0.20 - $0.25 per hour (spot; (us-east-1b))

SSH into the EC2 instance, and run the following:

```bash
$ cd /ifs/work/chunj/prism-proto/prism/bin/setup
$ sed -i "s|/usr/bin/singularity|/usr/local/bin/singularity|g" settings.sh
```

### r4.2xlarge

```bash
$ cd /ifs/work/chunj/prism-proto/prism/bin/setup
$ ./prism-init.sh -u ubuntu -s
```

### t2.micro

```bash
$ cd /tmp/prism-setup-1.0.0/scripts
$ ./reduce-resources-requirements.sh
```

Log out and log back in.


See if you can run the sam2bam workflow:

```bash
$ cd $PRISM_INPUT_PATH/ubuntu/examples/samtools-sam2bam
$ ./run-example.sh
```
