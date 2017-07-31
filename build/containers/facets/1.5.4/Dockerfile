FROM python:2.7.13-alpine3.6
MAINTAINER Nikhil Kumar (kumarn1@mskcc.org)

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.facets_suite="1.5.4" \
      version.facets="0.5.6"\
      version.alpine="3.6" \
      version.r="3.3.3-r0" \
      version.pctGCdata="0.2.0" \
      source.facets_suite="https://github.com/mskcc/facets-suite/releases/tag/1.5.4" \
      source.facets="https://github.com/mskcc/facets/archive/v0.5.6.tar.gz"\
      source.r="https://pkgs.alpinelinux.org/package/edge/community/x86/R"

ENV FACETS_SUITE_VERSION 1.5.4
ENV FACETS_VERSION 0.5.6
ENV R_VERSION 3.3.3-r0
ENV PCTGCDATA 0.2.0

COPY facets-suite-1.5.4.tar.gz /tmp/facets-suite-1.5.4.tar.gz
COPY install-packages.R /tmp/install-packages.R

RUN apk add --update \
      # for wget
      && apk add ca-certificates openssl \
      # for compilation
      && apk add build-base musl-dev \
      # install cairo and R package system dependencies
      && apk add cairo cairo-dev libxt-dev libxml2-dev \
      # download and install R
      && apk add R=${R_VERSION} R-dev=${R_VERSION} R-doc=${R_VERSION} \
      # download, unzip, install
      && cd /tmp \
      # download Facets
      && wget https://github.com/mskcc/facets/archive/v${FACETS_VERSION}.tar.gz \
      # download pctGCdata
      && wget https://github.com/mskcc/pctGCdata/archive/v${PCTGCDATA}.tar.gz \
      # unpack Facets
      && tar xvzf v${FACETS_VERSION}.tar.gz \
      # unpack pctGCdata
      && tar xvzf v${PCTGCDATA}.tar.gz \
      # unpack Facets_Suite
      && tar xvzf facets-suite-${FACETS_SUITE_VERSION}.tar.gz \
      # install pctGCdata
      && cd /tmp/pctGCdata-${PCTGCDATA} \
      && R CMD INSTALL . \
      # install Facets
      && cd /tmp/facets-${FACETS_VERSION} \
      && R CMD INSTALL . \
      # install Facets-Suite R dependencies
      && cd /tmp \
      && Rscript --vanilla install-packages.R \
      # install Facets-Suite
      && cp /tmp/facets-suite-${FACETS_SUITE_VERSION}/* /usr/bin \
      # remove tmp files
      && rm -rf /tmp

ENTRYPOINT ["sh"]