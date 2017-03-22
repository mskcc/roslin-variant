FROM java:7-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.abra="0.92" \
      version.alpine="3.4.6" \
      source.abra="https://github.com/mozack/abra/releases/tag/v0.92"

ENV TOOL_VERSION 0.92

RUN apk add --update \
      && apk add ca-certificates openssl \      
      && cd /tmp && wget https://github.com/mozack/abra/releases/download/v${TOOL_VERSION}/abra-${TOOL_VERSION}-SNAPSHOT-jar-with-dependencies.jar \
      && mv /tmp/abra-${TOOL_VERSION}-SNAPSHOT-jar-with-dependencies.jar /usr/bin/abra.jar \
      && rm -rf /tmp/*

CMD ["java", "-jar", "/usr/bin/abra.jar", "--help"]
