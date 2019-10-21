FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.roslin="1.0.0" \
      version.alpine="3.8"

ENV ROSLIN_PIPELINE_VERSION 1.0.0
COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

ADD welcome.txt /

RUN apk add --update bash \
	&& chmod +x /usr/bin/runscript.sh \
    && exec /run_test.sh