FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.basicfiltering="0.2.1" \
      version.alpine="3.8" \
      source.basicfiltering="https://github.com/mskcc/basicfiltering/releases/tag/0.2.1"

ENV BASICFILTERING_VERSION 0.2.1
ENV HTSLIB_VERSION 1.5

RUN apk add --update \
      # install all the build-related tools
            && apk add build-base musl-dev python py-pip python-dev ca-certificates openssl gcc g++ make git curl curl-dev wget gzip musl-dev libgcrypt-dev zlib-dev bzip2-dev xz-dev ncurses-dev \
      # download, unzip, install htslib
            && cd /tmp \
            && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
            && tar xvjf htslib-${HTSLIB_VERSION}.tar.bz2 \
            && cd /tmp/htslib-${HTSLIB_VERSION} \
            && ./configure \
            && make && make install \
      # download, unzip, install basic-filtering
            && cd /tmp && wget https://github.com/mskcc/basicfiltering/archive/${BASICFILTERING_VERSION}.zip \
            && unzip ${BASICFILTERING_VERSION}.zip \
            && cd /tmp/basicfiltering-${BASICFILTERING_VERSION} \
            && python setup.py install \
      # install basic-filtering
            && mv /tmp/basicfiltering-${BASICFILTERING_VERSION} /usr/bin/basicfiltering \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["/bin/sh"]
