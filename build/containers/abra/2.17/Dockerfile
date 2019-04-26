FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.abra="2.17" \
      version.alpine="3.8" \
      version.java="8" \
      source.abra="https://github.com/mozack/abra2/releases/tag/v2.17"

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

ENV ABRA_VERSION 2.17

# install abra
RUN apk add --update \
      && apk add build-base musl-dev zlib-dev openjdk8-jre libc6-compat \
      && cd /tmp && wget https://github.com/mozack/abra2/releases/download/v${ABRA_VERSION}/abra2-${ABRA_VERSION}.jar \
      && mv /tmp/abra2-${ABRA_VERSION}.jar /usr/bin/abra.jar \
      && rm -rf /tmp/* \
      && chmod +x /usr/bin/runscript.sh \
      && exec /run_test.sh

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
