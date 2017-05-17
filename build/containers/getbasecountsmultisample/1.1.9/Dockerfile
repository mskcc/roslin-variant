FROM alpine:3.4
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.getBaseCountsMultiSample="1.1.9" \
      version.alpine="3.4.x" \
      source.getBaseCountsMultiSample="https://github.com/zengzheng123/GetBaseCountsMultiSample/releases/tag/v1.1.9"

ENV GET_BASE_COUNTS_MULTI_SAMPLE_VERSION 1.1.9

RUN apk add --update \
      && apk add ca-certificates openssl gcc g++ make cmake musl-dev zlib-dev \      
      && cd /tmp && wget https://github.com/zengzheng123/GetBaseCountsMultiSample/archive/v${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}.zip \
      && unzip v${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}.zip \
      && cd /tmp/GetBaseCountsMultiSample-${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}/bamtools-master/build \
      && sed -i "s|/ifs/data/zeng/count_error/CountErrors/|/tmp/GetBaseCountsMultiSample-${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION}/|g" CMakeCache.txt \
      && sed -i "s|/usr/bin/gmake|/usr/bin/make|g" CMakeCache.txt \
      && cmake . && make \
      && cp ../lib/libbamtools.so.2.3.0 /usr/lib/ \
      && cd /tmp/GetBaseCountsMultiSample-${GET_BASE_COUNTS_MULTI_SAMPLE_VERSION} \
      && make \
      && cp GetBaseCountsMultiSample /usr/bin/ \
      && rm -rf /tmp/*

ENTRYPOINT ["/usr/bin/GetBaseCountsMultiSample"]
CMD ["--help"]
