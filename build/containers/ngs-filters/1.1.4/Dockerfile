FROM python:2.7.13-alpine
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.ngsfilters="1.1.4" \
      version.r="3.3.2-r0" \
      version.alpine="3.4.6" \
      source.ngsfilters="https://github.com/mskcc/ngs-filters/tree/v1.1.4" \
      source.r="https://pkgs.alpinelinux.org/package/v3.5/community/x86_64/R"

ENV NGS_FILTERS_VERSION 1.1.4-beta
ENV R_VERSION 3.3.2-r0

# copy script that installs all the necessary R packages
COPY install-packages.R /tmp/

# copy python requirements.txt that lists all the dependencies
COPY requirements.txt /tmp/

RUN apk add --update \
      # for wget and bash
            && apk add ca-certificates openssl bash \
      # for compilation (R packages)
            && apk add build-base musl-dev \
      # install R (only avail in Alpine 3.5 community)
            && apk add R=${R_VERSION} R-dev=${R_VERSION} R-doc=${R_VERSION} --update-cache --repository http://dl-5.alpinelinux.org/alpine/v3.5/community --allow-untrusted \
      # install ngs-filters dependencies (coloredlogs, pandas, uuidgen from util-linux, git
            && pip install -r /tmp/requirements.txt \
            && apk add --update util-linux \
      # download, unzip, install ngs-filters
            && cd /tmp && wget https://github.com/mskcc/ngs-filters/archive/v${NGS_FILTERS_VERSION}.zip \
            && unzip v${NGS_FILTERS_VERSION}.zip \
      # copy to /usr/bin
            && cp -r /tmp/ngs-filters-${NGS_FILTERS_VERSION} /usr/bin/ngs-filters/ \
      # install R packages
            && cd /tmp/ && Rscript --vanilla install-packages.R \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/ngs-filters/run_ngs-filters.py"]
CMD ["--help"]
