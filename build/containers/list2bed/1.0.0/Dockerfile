FROM python:2.7.13-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.image="1.0.0" \
      version.list2bed="1.0.0" \
      version.alpine="3.4.6" \
      source.gatk="https://github.com/mskcc/list2bed/releases/tag/1.0.0"

ENV LIST2BED_VERSION 1.0.0

RUN apk add --update \
      # for wget
            && apk add ca-certificates openssl \
      # for compilation (pybedtools)
            && apk add build-base musl-dev zlib-dev bzip2-dev xz-dev cython \
      # install pybedtools
            && pip install pybedtools \
      # download, unzip list2bed
            && cd /tmp && wget https://github.com/mskcc/list2bed/archive/${LIST2BED_VERSION}.zip \
            && unzip ${LIST2BED_VERSION}.zip \
      # copy to /usr/bin
            && mv /tmp/list2bed-${LIST2BED_VERSION}/list2bed.py /usr/bin/ \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/list2bed.py"]
