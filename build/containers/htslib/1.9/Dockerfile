FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.bcftools="1.9" \
      version.htslib="1.9" \
      version.samtools="1.9" \
      version.alpine="3.8" \
      source.htslib="https://github.com/samtools/htslib/releases/tag/1.9" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/1.9" \
      source.bcftools="https://github.com/samtools/bcftools/releases/tag/1.9"

ENV BCFTOOLS_VERSION 1.9
ENV HTSLIB_VERSION 1.9
ENV SAMTOOLS_VERSION 1.9

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

RUN apk add --update make g++ zlib-dev bzip2-dev xz-dev ncurses-dev \
    && apk add ca-certificates openssl \
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
    # install bcftools
    && cd /tmp && wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && cd /tmp/ && tar xjvf bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && cd /tmp/bcftools-${BCFTOOLS_VERSION} \
    && make && make prefix=/usr install \
    # clean up
    && rm -rf /var/cache/apk/* /tmp/*

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
