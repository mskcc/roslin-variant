FROM python:2.7.13-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.basicfiltering="0.1.6" \
      version.alpine="3.4.6" \
      source.basicfiltering="https://github.com/mskcc/basicfiltering/releases/tag/0.1.6"

ENV BASICFILTERING_VERSION 0.1.6

# to build pybedtools : build-base musl-dev zlib-dev cython

RUN apk add --update \
      && apk add ca-certificates openssl \
      && apk add build-base musl-dev \
      # Fix numpy compilation
      && ln -s /usr/include/locale.h /usr/include/xlocale.h \
      && cd /tmp && wget https://github.com/mskcc/basicfiltering/archive/${BASICFILTERING_VERSION}.zip \
      && unzip ${BASICFILTERING_VERSION}.zip \
      && cd /tmp/basicfiltering-${BASICFILTERING_VERSION} \
      && python setup.py install \
      && cp ./pindel/filter_pindel.py /usr/bin/ \
      && cp ./mutect/filter_mutect.py /usr/bin/ \
      && cp ./vardict/filter_vardict.py /usr/bin/ \
      && cp ./somaticindeldetector/filter_sid.py /usr/bin \
      && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["/bin/sh"]
