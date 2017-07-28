FROM alpine:3.5
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.image="1.0.0" \
      version.htstools="0.1" \
      version.alpine="3.5.x" \
      source.htstools="https://github.com/mskcc/htstools/releases/tag/snp_pileup_0.1"

ENV HTSTOOLS_VERSION 0.1

# RUN apk add --update \
#       # for wget and bash
#             && apk add ca-certificates openssl bash \
#       # for compiling c++/c code
#             && apk add build-base \
#       # download, unzip, install htstools
#             && cd /tmp && wget https://github.com/mskcc/htstools/archive/snp_pileup_${HTSTOOLS_VERSION}.zip \
#             && unzip snp_pileup_${HTSTOOLS_VERSION}.zip

RUN apk add --update \
      # for wget and bash
            && apk add ca-certificates openssl bash \
      # for compiling c++/c code
            && apk add build-base \
      # download, unzip, install htstools
            && apk add git \
            && cd /tmp && git clone https://github.com/mskcc/htstools.git

ENTRYPOINT ["sh"]
