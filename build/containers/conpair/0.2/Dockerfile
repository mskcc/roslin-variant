FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.conpair="0.2" \
      version.alpine="3.8" \
      source.conpair="https://github.com/mskcc/Conpair/releases/tag/0.2" \
      source.r="https://pkgs.alpinelinux.org/package/edge/community/x86/R"      

ENV CONPAIR_VERSION 0.2

COPY install-packages.R /tmp/install-packages.R
COPY gatk-${GATK_VERSION}.jar /usr/bin/gatk.jar

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
        # install numpy and scipy
        && pip install numpy \
        && pip install scipy \
        # install java
        && apk add openjdk8-jre-base \
         # download and unzip conpair
        && cd /tmp && wget https://github.com/mskcc/Conpair/archive/${CONPAIR_VERSION}.tar.gz \
        && tar xvzf Conpair-${CONPAIR_VERSION}.tar.gz \
        # install conpair
        && cp /tmp/Conpair-${CONPAIR_VERSION}/* /usr/bin/conpair \
        # clean up
        && rm -rf /tmp/*

ENV PYTHONNOUSERSITE set

ENTRYPOINT ["/bin/bash"]
