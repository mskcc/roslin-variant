FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.conpair="0.3.1" \
      version.alpine="3.8" \
      version.gatk="3.3-0" \
      source.gatk="https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.3-0-g37228af" \
      source.conpair="https://github.com/mskcc/Conpair/releases/tag/0.3.1" \
      source.r="https://pkgs.alpinelinux.org/package/edge/community/x86/R"      

ENV CONPAIR_VERSION 0.3.1
ENV GATK_VERSION 3.3-0

COPY gatk-${GATK_VERSION}.jar /usr/bin/gatk.jar
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
        # install numpy and scipy
        && pip install numpy \
        && pip install scipy \
        # install java
        && apk add openjdk8-jre-base \
         # download and unzip conpair
        && cd /tmp && wget https://github.com/mskcc/Conpair/archive/${CONPAIR_VERSION}.tar.gz \
        && tar xvzf ${CONPAIR_VERSION}.tar.gz \
        # install conpair
        && mv /tmp/Conpair-${CONPAIR_VERSION} /usr/bin/conpair \
        # clean up
        && rm -rf /tmp/*

ENV PYTHONNOUSERSITE set

ENTRYPOINT ["/bin/sh"]
