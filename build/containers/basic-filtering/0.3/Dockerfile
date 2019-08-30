FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.basicfiltering="0.3" \
      version.alpine="3.8" \
      version.cmo="1.9.13" \
      version.bcftools="1.9" \
      source.cmo="https://github.com/mskcc/cmo/releases/tag/1.9.13" \
      source.basicfiltering="https://github.com/mskcc/basicfiltering/releases/tag/0.3" \
      source.bcftools="https://github.com/samtools/bcftools/releases/tag/1.9"

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

ENV BASICFILTERING_VERSION 0.3
ENV HTSLIB_VERSION 1.5
ENV CMO_VERSION 1.9.13
ENV BCFTOOLS_VERSION 1.9

RUN apk add --update \
      # install all the build-related tools
            && apk add build-base musl-dev python py-pip python-dev ca-certificates openssl gcc g++ make git curl curl-dev wget gzip musl-dev libgcrypt-dev zlib-dev bzip2-dev xz-dev ncurses-dev subversion \
      # download, unzip, install htslib
            && cd /tmp \
            && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
            && tar xvjf htslib-${HTSLIB_VERSION}.tar.bz2 \
            && cd /tmp/htslib-${HTSLIB_VERSION} \
            && ./configure \
            && make && make install \
      # download, unzip, install bcftools
            && cd /tmp \
            && wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
            && tar xjvf bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
            && cd /tmp/bcftools-${BCFTOOLS_VERSION} \
            && make && make prefix=/usr install \
      # download, unzip, install cmo
            && cd /tmp && wget https://github.com/mskcc/cmo/archive/${CMO_VERSION}.zip \
            && unzip ${CMO_VERSION}.zip \
            && cd /tmp/cmo-${CMO_VERSION} \
            && python setup.py install \
      # download, unzip, install basic-filtering
            && cd /tmp && wget https://github.com/mskcc/basicfiltering/archive/${BASICFILTERING_VERSION}.zip \
            && unzip ${BASICFILTERING_VERSION}.zip \
            && cd /tmp/basicfiltering-${BASICFILTERING_VERSION} \
            && python setup.py install \
      # install basic-filtering
            && mv /tmp/basicfiltering-${BASICFILTERING_VERSION} /usr/bin/basicfiltering \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/* \
            && chmod +x /usr/bin/runscript.sh \
            && exec /run_test.sh

# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
