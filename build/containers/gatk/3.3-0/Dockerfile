FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.gatk="3.3-0" \
      version.alpine="3.8" \
      version.java="8" \
      source.gatk="https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.3-0-g37228af"

ENV GATK_VERSION 3.3-0
ENV GATK_DOWNLOAD_URL https://s3.us-east-2.amazonaws.com/roslindata/gatk-3.3-0.jar

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh


RUN apk add --update \
      && apk add build-base musl-dev zlib-dev openjdk8-jre \
      && apk add ca-certificates openssl \
      && wget ${GATK_DOWNLOAD_URL} -O /usr/bin/gatk.jar \
      && chmod +x /usr/bin/runscript.sh \
      && exec /run_test.sh