FROM openjdk:6

LABEL maintainer="C. Allan Bolipata (bolipatc@mskcc.org)" \
      version.image="1.0.0" \
      version.mutect="1.1.4" \
      version.java="6" \
      source.mutect="https://github.com/broadinstitute/mutect/releases/tag/1.1.4"

ENV MUTECT_VERSION 1.1.4

COPY mutect-${MUTECT_VERSION}.jar /usr/bin/mutect.jar
COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
