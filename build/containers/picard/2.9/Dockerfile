FROM alpine:3.5

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.picard="2.9" \
      version.alpine="3.5" \
      source.picard="https://github.com/broadinstitute/picard/releases/tag/2.9.0"

ENV TOOL_VERSION 2.9.0
ENV R_VERSION 3.3.2-r0

RUN apk add --update \
      && apk add ca-certificates openssl \
      && apk add openjdk8-jre-base \$
      && apk add R=${R_VERSION} --update-cache --repository http://dl-5.alpinelinux.org/alpine/v3.5/community --allow-untrusted \
      && cd /tmp && wget https://github.com/broadinstitute/picard/releases/download/${TOOL_VERSION}/picard.jar \
      && mkdir /usr/bin/picard-tools/ \
      && mv /tmp/picard.jar /usr/bin/picard-tools/picard.jar \
      && rm -rf /var/cache/apk/* /tmp/*

ENTRYPOINT ["java", "-jar", "/usr/bin/picard-tools/picard.jar"]
