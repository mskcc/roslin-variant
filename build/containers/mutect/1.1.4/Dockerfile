FROM java:7-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.mutect="1.1.4" \
      version.alpine="3.4.6" \
      source.mutect="https://github.com/broadinstitute/mutect/releases/tag/1.1.4"

ENV MUTECT_VERSION 1.1.4

COPY mutect-${MUTECT_VERSION}.jar /usr/bin/mutect.jar

CMD ["java", "-jar", "/usr/bin/mutect.jar", "--help"]

