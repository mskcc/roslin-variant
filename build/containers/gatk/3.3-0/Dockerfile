FROM java:8-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.gatk="3.3-0" \
      version.alpine="3.4.6" \
      source.picard="https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.3-0-g37228af"

ENV TOOL_VERSION 3.3-0

COPY gatk-${TOOL_VERSION}.jar /usr/bin/gatk.jar

CMD ["java", "-jar", "/usr/bin/gatk.jar", "--help"]
