FROM java:8-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.picard="1.129" \
      version.alpine="3.4.6" \
      source.picard="https://github.com/broadinstitute/picard/releases/tag/1.129"

ENV TOOL_VERSION 1.129

RUN apk add --update \
      && apk add ca-certificates openssl \
      && cd /tmp && wget https://github.com/broadinstitute/picard/releases/download/${TOOL_VERSION}/picard-tools-${TOOL_VERSION}.zip \
      && unzip picard-tools-${TOOL_VERSION}.zip \
      && mv /tmp/picard-tools-${TOOL_VERSION} /usr/bin/picard-tools \
      && rm -rf /var/cache/apk/* /tmp/*

ENTRYPOINT ["java", "-jar", "/usr/bin/picard-tools/picard.jar"]
