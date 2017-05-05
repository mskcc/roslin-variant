## Create Setup Package

This document covers Step 4:

![/docs/prism-build-to-deploy.png](/docs/prism-build-to-deploy.png)

## Luna

There are many ways, but the latest deploymnent script for Luna does rsync on `/setup`, thus no special setup package is required at the moment.

## Amazon Web Services (AWS)

There are many ways, but the latest method uses:

From Local:

```
Create Setup Package --> Upload to S3 --> Launch EC2 Instance
```

From EC2 Instance:

```
Download Setup Package from S3 --> Install
```

### Prerequisites

The versions mentioned here are the ones that are tested. This does not necessarily mean that higher versions would automatically work.

- Amazone Web Services account
- [AWS Command Line Interface v1.11.56](https://aws.amazon.com/cli/)

For setting up, refer to this document: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration

### Compress

Unless you are trying to release the new changes, you can skip this step.

Run the following command outside the vagrant box. This will create `prism-v1.0.0.tgz`.

```bash
$ ./compress.sh
```

### Upload to S3

Upload the compressed file to AWS S3:

```bash
$ aws s3 cp prism-v1.0.0.tgz s3://prism-installer/
```
