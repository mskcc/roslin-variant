FROM java:7-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.gatk="3.3-0" \
      version.alpine="3.4.6" \
      source.gatk="https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.3-0-g37228af"

ENV GATK_VERSION 3.3-0

COPY gatk-${GATK_VERSION}.jar /usr/bin/gatk.jar

ENTRYPOINT ["java", "-jar", "/usr/bin/gatk.jar"]
CMD ["--help"]
