FROM java:8-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.vardict="1.4.6" \
      version.alpine="3.4.6" \
      source.vardict="https://github.com/AstraZeneca-NGS/VarDictJava/releases/tag/v1.4.6"

ENV VARDICT_VERSION 1.4.6

RUN apk add --update \
      && apk add ca-certificates openssl bash \
      && cd /tmp && wget https://github.com/AstraZeneca-NGS/VarDictJava/releases/download/v${VARDICT_VERSION}/VarDict-${VARDICT_VERSION}.zip \
      && unzip VarDict-${VARDICT_VERSION}.zip \
      && mv /tmp/VarDict-${VARDICT_VERSION} /usr/bin/vardict \
      && rm -rf /tmp/*

ENTRYPOINT ["/usr/bin/vardict/bin/VarDict"]
