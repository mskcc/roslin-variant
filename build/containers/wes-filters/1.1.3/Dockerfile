FROM alpine:3.5
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.wesfilters="1.1.3" \
      version.r="3.3.2-r0" \
      version.python="2.7.13-r0" \
      version.alpine="3.5.x" \
      source.wesfilters="https://github.com/mskcc/wes-filters/tree/v1.1.3" \
      source.r="https://pkgs.alpinelinux.org/package/v3.5/community/x86_64/R"

ENV WESFILTERS_VERSION 1.1.3
ENV R_VERSION 3.3.2-r0
ENV PYTHON_VERSION 2.7.13-r0

# copy script that installs all the necessary R packages
COPY install-packages.R /tmp/

RUN apk add --update \
      # for wget and bash
            && apk add ca-certificates openssl bash \
      # for compilation (R packages)
            && apk add build-base musl-dev \
      # install R (only avail in Alpine 3.5 community)
            && apk add R=${R_VERSION} --update-cache --repository http://dl-5.alpinelinux.org/alpine/v3.5/community --allow-untrusted \
            && apk add R-dev=${R_VERSION} \
            && apk add R-doc=${R_VERSION} \
      # install python
            && apk add --update python=${PYTHON_VERSION} \
      # download, unzip, install wes-filters
            && cd /tmp && wget https://github.com/mskcc/wes-filters/archive/v${WESFILTERS_VERSION}.zip \
            && unzip v${WESFILTERS_VERSION}.zip \
      # copy to /usr/bin
            && cp -r /tmp/wes-filters-${WESFILTERS_VERSION} /usr/bin/wes-filters/ \
      # install R packages
            && cd /tmp/ && Rscript --vanilla install-packages.R \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["/bin/bash"]
