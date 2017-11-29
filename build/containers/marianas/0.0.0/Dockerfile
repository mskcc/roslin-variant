FROM java:8-alpine

LABEL maintainer="Ian Johnson (johnsoni@mskcc.org)" \
      version.image="0.0.0" \
      version.gatk="0.0.0" \
      version.alpine="3.4.6" \
      source.marianas="https://github.com/juberpatel/Marianas"

ENV MARIANAS_VERSION 0.0.0

COPY marianas-${MARIANAS_VERSION}.jar /usr/bin/marianas-0.0.0.jar

RUN chmod 777 /usr/bin/marianas-0.0.0.jar

ENTRYPOINT ["java", "-jar", "/usr/bin/marianas-0.0.0.jar"]
# CMD ["--help"]
