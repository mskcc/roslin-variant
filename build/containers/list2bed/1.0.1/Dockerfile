FROM python:2.7.13-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.list2bed="1.0.1" \
      version.alpine="3.4.6" \
      source.list2bed="https://github.com/mskcc/list2bed/releases/tag/1.0.1"

ENV LIST2BED_VERSION 1.0.1

# to build pybedtools : build-base musl-dev zlib-dev cython
RUN apk add --update \
      && apk add ca-certificates openssl \
      && apk add build-base musl-dev zlib-dev bzip2-dev xz-dev cython \
      && pip install pybedtools \
      && cd /tmp && wget https://github.com/mskcc/list2bed/archive/${LIST2BED_VERSION}.zip \
      && unzip ${LIST2BED_VERSION}.zip \
      && mv /tmp/list2bed-${LIST2BED_VERSION}/list2bed.py /usr/bin/ \
      && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/list2bed.py"]
