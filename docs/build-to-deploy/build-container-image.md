# Create Container Imge

This document will walk you through using *BCFTools v1.3.1* as an example.

## Bird's Eye View

![/docs/image-build-process.png](/docs/image-build-process.png)

## tools.json

Add an entry to `/build/scripts/tools.json`.

```
{
    "programs": {
        ...
        "bcftools": [
            "1.3.1"
        ],
        ...
    }
}
```

There could be multiple versions for a given tool. In this case, you can simply add a new vesion to the existing entry, for example:

```
{
    "programs": {
        ...
        "bwa": [
            "0.7.15",
            "0.7.12",
            "0.7.5a"
        ],
        ...
    }
}
```

## Create Directory

Create a directory `/bulid/containers/bcftools/1.3.1`.

At the end of the day, this directory would look something like below:

```bash
/build/containers/bcftools
└── 1.3.1
    ├── bcftools.img
    ├── Dockerfile
    ├── .dockerignore
    └── Singularity
```

where `bcftools.img` is the final artifact.

## Dockerfile

Create a file named `Dockerfile`. This will contain metadata and steps to dockerize the tool, e.g. bcftools. These steps usually include either downloading/compiling the tool's source code or downloading/copying the final binaries/executables, or sometimes even both.

If the tool you're trying to containerize is written in

- C or C++:
    - Install C/C++ compilers and other necessary build tools.
    - Download the source code and compile inside the container.
- Java:
    - Instal JRE or JDK in the container.
    - You can either compile the tool's Java source code or simply copy the final Jar file(s) into the container.
- Perl:
    - Install Perl in the container.
    - Simply including the `*.pl` files(s) in the container should be sufficient.
- Python:
    - Install Python in the container.
    - Simply including the `*.py` file(s) in the container should be sufficient, but make sure to install all the necessary dependencies or preferrably install the tool using `pip` or `python setup.py install`.
- R:
    - Install R in the container.
    - Simply including the `*.R` file(s) in the container should be sufficient, but make sure to install all the necessary dependencies.

Use the template as the basis and make necessary changes. Below is PINDEL example:

```
#1
FROM alpine:3.5

#2
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

#3
LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.pindel="0.2.5a7" \
      version.samtools="0.1.19" \
      version.alpine="3.5.x" \
      source.pindel="https://github.com/genome/pindel/releases/tag/0.2.5a7" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/0.1.19"

#4
ENV PINDEL_VERSION 0.2.5a7
ENV SAMTOOLS_VERSION 0.1.19

#5
RUN apk add --update make g++ zlib-dev bzip2-dev xz-dev ncurses-dev \
      && apk add ca-certificates openssl \
      && cd /tmp && wget https://github.com/samtools/samtools/archive/${SAMTOOLS_VERSION}.zip \
      && unzip ${SAMTOOLS_VERSION}.zip \
      && cd /tmp/samtools-${SAMTOOLS_VERSION} \
      && make \
      && cd /tmp && wget https://github.com/genome/pindel/archive/v${PINDEL_VERSION}.zip \
      && unzip v${PINDEL_VERSION}.zip \
      && cd /tmp/pindel-${PINDEL_VERSION} \
      && sed -i[.bak] '1i#include <cmath>' ./src/bddata.cpp \
      && ./INSTALL /tmp/samtools-${SAMTOOLS_VERSION} \
      && mv /tmp/pindel-${PINDEL_VERSION}/pindel /usr/bin \
      && mv /tmp/pindel-${PINDEL_VERSION}/pindel2vcf /usr/bin \
      && mv /tmp/pindel-${PINDEL_VERSION}/sam2pindel /usr/bin \
      && rm -rf /var/cache/apk/* /tmp/*

#6
ENTRYPOINT ["/usr/bin/pindel"]

#7
CMD ["-h"]
```

### #1 FROM

Specify a base image to be used:

- Use Alpine Linux if possible to minimize the footprint.
- Try to use a very specific version of the base image (e.g. `alpine:3.5`)
- Some base Docker images come with pre-installed Java, Python, ...
    - `java:7-alpine`
    - `java:8-alpine`
    - `python:2.7.13-alpine`

### #2 MAINTAINER

Specify the maintainer's full name and email address.

### #3 LABEL

Include metadata:

- `maintainer` : Same as #2
- `version.container` : Version of this container
- `version.???`
    - Version of the tool being containerized.
    - Replace `???` with the tool name (e.g. `version.bcftools`)
    - If multiple tools are being containerized, you must specify the versions of all the tools being containerized (e.g. `version.pindel="0.2.5a7"` and `version.samtools="0.1.19"`)
- `version.alpine`
    - Version of the base image.
    - `alpine` is the name of the base image in this case.
- `source.???`
    - Usually a link to the GitHub repository that stores the specific version of the tool being containerized.
    - Replace `???` with the tool name (e.g. `source.bcftools`)
    - If multiple tools are being containerized, you must specify the sources of all the tools being containerized (e.g. `source.pindel="https://github.com/genome/pindel/releases/tag/0.2.5a7"` and `source.samtools="https://github.com/samtools/samtools/releases/tag/0.1.19"`)

### #4 ENV

Store the version(s) of the tool(s) in the environment variable:

- `ENV ???_VERSION x.y.z` where `???` is the name of the tool being containerized, `x.y.z` is the version of the tool.
- If multiple tools are being containerized, you must create multiple `ENV`s.

### #5 RUN

Include steps to build the tool(s).

- Do not hardcode the tool version, instead use the environment variable declared in #4 (e.g. `${BCFTOOLS_VERSION}`)
- Try to use a *single* `RUN` command by concatenating multiple commands using `&&`. This way, we can minimize the number of layers being created, thus small footprint.
- If you are compiling the source code, make sure the final binaries/executables are placed in `/usr/bin/`.
- Make sure to remove any temporary directories created during the process in order to minimize the footprint.
- Make sure there are no tailing white spaces, especially if you have multi-lines separated with `\`.

### #6 ENTRYPOINT

Add a command that invokes the tool being containerized (without any tool-specific parameters)

### #7 CMD

- Add a tool-specific parameter that will be called with when a user runs the container without specifying any parameters.
- If user does specify parameters at runtime, whatever parameters you specify here will be overriden.

## .dockerignore

Create a file named `.dockerignore`. 

- Usually, you do not want to transfer context to Docker daemon, so add `*` to the file.
- However, if you are copying files from the host to the container image, you must make sure that the files are mentioned in the `.dockerignore` as an exception.
- e.g. gatk.2.3-9

    ```
    *
    !gatk-2.3-9.jar
    ```

## Singularity

Create a file named `Singularity`.

This will contain metadata and steps to convert the dockerized tool to a Singularity image.

Use the template as the basis and make necessary changes.

```
Bootstrap: docker

#1
From: /pipeline-bcftools:1.3.1

Registry: http://localhost:5000

%setup

    # copy settings-container.sh from the host to the container
    cp /vagrant/build/scripts/settings-container.sh $SINGULARITY_ROOTFS/tmp

%post

    # load the settings-container.sh which was copied in the %setup step
    source /tmp/settings-container.sh
    
    # create an empty directory for each bind point defined
    for dir in $SINGULARITY_BIND_POINTS
    do
        mkdir -p $dir
    done

    # remove settings-container.sh
    rm -rf /tmp/settings-container.sh

#2
%runscript

    exec /usr/bin/bcftools "$@"

#3
%test

    # get actual output of the tool
    exec /usr/bin/bcftools "$@"

    # expected output
cat > /tmp/expected.diff.txt << EOM
Program: bcftools (Tools for variant calling and manipulating VCFs and BCFs)
Version: 1.3.1 (using htslib 1.3.1)
EOM

    # diff
    diff /tmp/actual.diff.txt /tmp/expected.diff.txt

    # delete tmp
    rm -rf /tmp/*.diff.txt
```

Some of the sections such as `%setup` and `%post` do not need to be modified. Unless you know what you're doing, make changes only in the sections mentioned below.

### #1 From

Specify the tool's docker image name and version. Note that the prefix `pipeline-` must be prepended.

### #2 %runscript

- Add a command that invokes the tool being containerized (without any tool-specific parameters)
- Make sure to call with `exec`.
- Make sure to append `"$@"` so that tool-specific parameters can be properly passed.

### #3 %test

- Add unit test code to verify that the tool is correctly containerized.
- In general, you'd want to call the tool and check the version or help message.

## Build and Verify

Note that this part must be done inside the virtual machine.

To see what tools can be built, run `build-image.sh` with the `-z` parameter:

```bash
$ cd /vagrant/build/scripts/
$ ./build-images.sh -z
samtools:1.3.1
trimgalore:0.4.3
trimgalore:0.2.5.mod
pindel:0.2.5b8
pindel:0.2.5a7
basic-filtering:0.1.6
picard:1.96
mutect:1.1.4
vardict:1.4.6
bwa:0.7.15
bwa:0.7.12
bwa:0.7.5a
abra:0.92
gatk:3.3-0
gatk:2.3-9
bcftools:1.3.1
list2bed:1.0.1
```

To build a specific tool, run `build-image.sh` with the `-t` parameter:
```bash
$ cd /vagrant/build/scripts/
$ ./build-images.sh -t bcftools:1.3.1 -d
```

Once the build has been completed with no errors, verify if you can run it:

```bash
$ sudo docker run -it --rm bcftools:1.3.1
```

If everything looks good, run `build-image.sh` again, but this time without the `-d` parameter. This will not only create the Docker image, but also convert the Docker image to a Singularity image using the `Singularity` file we created previously.

```bash
$ ./build-images.sh -t bcftools:1.3.1
```

Verify if you can run the singularity container:

```bash
$ singularity run /vagrant/build/containers/bcftools/1.3.1/bcftools.img
```

Verify if the bind points are properly built into the image:

```bash
$ singularity exec /vagrant/build/containers/bcftools/1.3.1/bcftools.img ls /
```
