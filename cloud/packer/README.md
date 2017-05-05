# prism-node-packer

Build Amazon Machine Image or DigitalOcean image using Packer.

## Preparation

Output the various components a template defines

```bash
$ packer inspect prism-node.packer
```

Validate a syntax and configuration of a template 

```
$ packer validate prism-node.packer
```

## Credentials for Providers

### AWS

- Set via environment variable either `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` or `AWS_PROFILE`.
- https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials

### DigitalOcean

- Set via environment variable `DIGITALOCEAN_API_TOKEN`.
- https://www.packer.io/docs/builders/digitalocean.html#required-

## Build

### Building for a Specific Provider

```bash
$ packer build -only=amazon-ebs prism-node.packer
$ packer build -only=digitalocean prism-node.packer
```

### Building with a Specific Version of `cwltoil`

- `official` (default)
- `mskcc`

```
$ packer build -var 'cwltoil_version=mskcc' prism-node.packer
```

### Building for AWS with MSKCC CWLTOIL

```bash
$ packer build -only=amazon-ebs -var 'cwltoil_version=mskcc' prism-node.packer
```

## Verifying Software Version Installed

```bash
$ cat /var/log/prism-software-versions.txt
```

## Other References

- https://www.packer.io/intro/getting-started/parallel-builds.html#setting-up-digitalocean
