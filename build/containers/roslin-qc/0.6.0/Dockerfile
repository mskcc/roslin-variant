FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.roslin-qc="0.6.0" \
      version.alpine="3.8" \
      source.roslin-qc="https://github.com/mskcc/roslin-qc/tree/for_roslin_2.5.0" \
      source.r="https://pkgs.alpinelinux.org/package/edge/community/x86/R"

ENV ROSLIN_QC_VERSION 0.6.0

COPY roslin-qc-${ROSLIN_QC_VERSION}.tar.gz /tmp/roslin-qc-${ROSLIN_QC_VERSION}.tar.gz
COPY install-packages.R /tmp/install-packages.R

RUN apk add --update \
    # for wget
    && apk add ca-certificates openssl \
    # for compilation
    && apk add build-base musl-dev python py-pip python-dev py-setuptools\
    && cd /tmp \
        # install R
        && apk add R R-dev \
        # install R dependencies
        && Rscript --vanilla install-packages.R \
        # install mysql connector
        && pip install mysql-connector==2.1.4 \
        # install pandas
        && pip install django==1.11 \
        && pip install dbconfig \
        && pip install pandas \
        # install python dependencies
        && pip install fnmatch2 argparse \
        # install java and perl
        && apk add openjdk8-jre-base perl \
        # unpack roslin-qc
        && tar xvzf roslin-qc-${ROSLIN_QC_VERSION}.tar.gz \
        # FIX ALL THESE WRONG FILE PATHS
        && cd roslin-qc-${ROSLIN_QC_VERSION} \
        && sed -i "s/opt\/common\/CentOS_6-dev\//usr\//g" *.pl \
        && sed -i "s/opt\/common\/CentOS_6\/python\/python-2.7.8\//usr\/local\//g" *.py \
        && sed -i "s/opt\/common\/CentOS_6\/R\/R-3.2.0\//usr\//g" *.R \
        && sed -i "s/opt\/common\//usr\/local\//g" *.py \
        # Install perl dependency needed
        && perl -MCPAN -e 'install Tie::IxHash' \
        # send scripts to the bin directory
        && cp -r /tmp/roslin-qc-${ROSLIN_QC_VERSION}/* /usr/bin \
        # clean up
        && rm -rf /tmp/*

ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/generate_pdf.py"]
