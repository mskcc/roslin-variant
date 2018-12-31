FROM ubuntu:14.04

LABEL maintainer="C. Allan Bolipata (bolipatc@mskcc.org)" \
      version.image="1.0.0" \
      version.mutect="1.1.4" \
      version.java="6" \
      source.mutect="https://github.com/broadinstitute/mutect/releases/tag/1.1.4"

ENV MUTECT_VERSION 1.1.4
ENV JAVA_HOME /usr/lib/jvm/java-6-openjdk-amd64

# Install Java.
RUN \
  apt-get update && \
  apt-get install -y openjdk-6-jdk && \
  rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
COPY mutect-${MUTECT_VERSION}.jar /usr/bin/mutect.jar

CMD ["java", "-jar", "/usr/bin/mutect.jar", "--help"]
