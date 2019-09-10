FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.getBaseCountsMultiSample="1.2.2" \
      version.samtools="1.9" \
      version.htslib="1.9" \
      version.alpine="3.8" \
      version.cmo="1.9.14" \
      source.htslib="https://github.com/samtools/htslib/releases/tag/1.9" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/1.9" \
      source.getBaseCountsMultiSample="https://github.com/zengzheng123/GetBaseCountsMultiSample/releases/tag/v1.2.2" \
      source.cmo="https://github.com/mskcc/cmo/releases/tag/1.9.14"


ENV GET_BASE_COUNTS_MULTI_SAMPLE_VERSION 1.2.2
ENV CMO_VERSION 1.9.14
ENV HTSLIB_VERSION 1.9
ENV SAMTOOLS_VERSION 1.9

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh
COPY cmo_resources.json /usr/bin/cmo_resources.json

RUN apk add --update \
      # install all the build-related tools
            && apk add cmake jsoncpp build-base musl-dev python py-pip python-dev ca-certificates openssl gcc g++ make git curl curl-dev wget gzip musl-dev libgcrypt-dev zlib-dev bzip2-dev xz-dev ncurses-dev subversion \
      # download and unzip gbcms
            && cd /tmp && wget https://github.com/zengzheng123/GetBaseCountsMultiSample/archive/v${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}.zip \
            && unzip v${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}.zip \
            # install htslib
            && cd /tmp && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
            && tar xvjf htslib-${HTSLIB_VERSION}.tar.bz2 \
            && cd /tmp/htslib-${HTSLIB_VERSION} \
            && ./configure \
            && make && make install \
            # install samtools
            && cd /tmp && wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
            && tar xvjf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
            && cd /tmp/samtools-${SAMTOOLS_VERSION} \
            && ./configure --with-htslib=/tmp/htslib-${HTSLIB_VERSION} \
            && make && make install \
      # build and install bamtools
            && cd /tmp/GetBaseCountsMultiSample-${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}/bamtools-master \
            && rm -r build/ \
            && mkdir build \
            && cd build/ \
            && cmake -DCMAKE_CXX_FLAGS=-std=c++03 .. \
            && make \
            && make install \
      # copy libbamtools to /usr/lib/
            && cp ../lib/libbamtools.so.2.3.0 /usr/lib/ \
      # install getBaseCountsMultiSample
            && cd /tmp/GetBaseCountsMultiSample-${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION} \
            && make \
      # copy bins to /usr/lib/
            && cp GetBaseCountsMultiSample /usr/bin/ \
      # download, unzip, install cmo
            && cd /tmp && wget https://github.com/mskcc/cmo/archive/${CMO_VERSION}.zip \
            && unzip ${CMO_VERSION}.zip \
            && cd /tmp/cmo-${CMO_VERSION} \
            && mkdir -p /opt/common/CentOS_6-dev/cmo/ \
            && cp /usr/bin/cmo_resources.json /opt/common/CentOS_6-dev/cmo/ \
            && python setup.py install \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/* \
            && chmod +x /usr/bin/runscript.sh \
            && exec /run_test.sh
# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
