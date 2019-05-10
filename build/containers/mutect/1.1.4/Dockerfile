FROM openjdk:6

LABEL maintainer="C. Allan Bolipata (bolipatc@mskcc.org)" \
      version.image="1.0.0" \
      version.mutect="1.1.4" \
      version.java="6" \
      source.mutect="https://github.com/broadinstitute/mutect/releases/tag/1.1.4"

ENV MUTECT_VERSION 1.1.4
ENV MUTECT_DOWNLOAD_URL https://s3.us-east-2.amazonaws.com/roslindata/mutect-1.1.4.jar

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

RUN chmod +x /usr/bin/runscript.sh \
	&& wget ${MUTECT_DOWNLOAD_URL} -O /usr/bin/mutect.jar \
	&& exec /run_test.sh

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
