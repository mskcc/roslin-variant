## Create Setup Package

This document covers Step 4:

```
1) Set Up VM --> 2) Build --> 3) Move Artifacts --> 4) Create Setup Package --> 5) Deploy
```

## Luna

There are many ways available, but the latest deploymnent script for Luna does rsync on `/setup`, thus no special setup package is required at the moment.

## AWS

There are many ways available, but the latest method uses:

From Local:

```
Create Setup Package --> Upload to S3 --> Launch EC2 Instance
```

From EC2 Instance:

```
Download Setup Package from S3 --> Install
```

### Compress

Unless you are trying to release the new changes, you can skip this step.

Run the following command outside the vagrant box. This will create `prism-v1.0.0.tgz`.

```bash
$ ./compress.sh
```

Upload the compressed file to AWS S3:

```bash
$ aws s3 cp prism-v1.0.0.tgz s3://prism-installer/
```
