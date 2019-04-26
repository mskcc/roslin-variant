FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.gatk="3.3-0" \
      version.alpine="3.8" \
      version.java="8" \
      source.gatk="https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.3-0-g37228af"

ENV GATK_VERSION 3.3-0

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh
COPY gatk-${GATK_VERSION}.jar /usr/bin/gatk.jar

RUN apk add --update \
      && apk add build-base musl-dev zlib-dev openjdk8-jre \
      && chmod +x /usr/bin/runscript.sh \
      && exec /run_test.sh

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
