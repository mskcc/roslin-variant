FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.facets_suite="1.6.2" \
      version.facets="0.5.14"\
      version.alpine="3.8" \
      version.r="3.5.1" \
      version.pctGCdata="0.2.0" \
      source.facets_suite="https://github.com/mskcc/facets-suite/releases/tag/1.6.2" \
      source.facets="https://github.com/mskcc/facets/archive/v0.5.14.tar.gz"\
      source.r="https://pkgs.alpinelinux.org/package/edge/community/x86/R"

ENV FACETS_SUITE_VERSION 1.6.2
ENV FACETS_VERSION 0.5.14
ENV PCTGCDATA 0.2.0

# copy script that installs R packages
COPY install-packages.R /tmp/install-packages.R
COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

RUN apk add --update \
    # for wget
        && apk add ca-certificates openssl \
    # for compilation
        && apk add build-base musl-dev python py-pip python-dev \
    # install cairo and R package system dependencies
        && apk add cairo cairo-dev libxt-dev libxml2-dev font-xfree86-type1 \
    # download and install R
        && apk add R R-dev \
    # download and unzip facets, facets-suite, pctGCdata
        && cd /tmp \
        # download Facets
            && wget https://github.com/mskcc/facets/archive/v${FACETS_VERSION}.tar.gz \
        # download pctGCdata
            && wget https://github.com/mskcc/pctGCdata/archive/v${PCTGCDATA}.tar.gz \
        # download Facets_suite
            && wget https://github.com/mskcc/facets-suite/archive/${FACETS_SUITE_VERSION}.tar.gz \
        # unpack Facets
            && tar xvzf v${FACETS_VERSION}.tar.gz \
        # unpack pctGCdata
            && tar xvzf v${PCTGCDATA}.tar.gz \
        # unpack Facets_Suite
            && tar xvzf ${FACETS_SUITE_VERSION}.tar.gz \
    # install
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
            && cd /tmp/facets-suite-${FACETS_SUITE_VERSION} \
            # correct shebang line
                && sed -i "s/opt\/common\/CentOS_6-dev\/R\/R-3.2.2\//usr\//g" *.R \
                && sed -i "s/opt\/common\/CentOS_6-dev\/R\/R-3.4.1\//usr\//g" *.R \
                && sed -i "s/opt\/common\/CentOS_6-dev\/R\/R-3.1.3\//usr\//g" *.R \
                && sed -i "s/opt\/common\/CentOS_6-dev\/python\/python-2.7.10\/bin\/python/usr\/bin\/env python/g" facets \
                && sed -i "s/opt\/common\/CentOS_6-dev\/bin\/current\/python/usr\/bin\/env python/g" summarize_project.py \
                #&& sed -i "s/IMPACT468_targets <-/# IMPACT468_targets <-/g" geneLevel.R \
                #&& sed -i "s/msk_impact_468 <-/# msk_impact_468 <-/g" geneLevel.R \
                #&& sed -i "s/setnames(IMPACT468_targets/# setnames(IMPACT468_targets/g" geneLevel.R \
                #&& sed -i "s/IMPACT410_targets =/# IMPACT410_targets =/g" geneLevel.R \
                #&& sed -i "s/setkey(IMPACT468_targets/# setkey(IMPACT468_targets/g" geneLevel.R \
                #&& sed -i "s/IMPACT410_targets <-/# IMPACT410_targets <-/g" geneLevel.R \
                #&& sed -i "s/msk_impact_410 <-/# msk_impact_410 <-/g" geneLevel.R \
                #&& sed -i "s/setnames(IMPACT410_targets/# setnames(IMPACT410_targets/g" geneLevel.R \
                #&& sed -i "s/IMPACT468_targets =/# IMPACT468_targets =/g" geneLevel.R \
                #&& sed -i "s/setkey(IMPACT410_targets/# setkey(IMPACT410_targets/g" geneLevel.R \
                #&& sed -i "s/IMPACT341_targets <-/# IMPACT341_targets <-/g" geneLevel.R \
                #&& sed -i "s/msk_impact_341 <-/# msk_impact_341 <-/g" geneLevel.R \
                #&& sed -i "s/setnames(IMPACT341_targets/# setnames(IMPACT341_targets/g" geneLevel.R \
                #&& sed -i "s/setkey(IMPACT341_targets/# setkey(IMPACT341_targets/g" geneLevel.R \
            # copy execs to /usr/bin/facets-suite
                && mkdir -p /usr/bin/facets-suite/ \
                && cp /tmp/facets-suite-${FACETS_SUITE_VERSION}/* /usr/bin/facets-suite/ \
    # clean up
        && rm -rf /var/cache/apk/* /tmp/* \
        && chmod +x /usr/bin/runscript.sh \
        && exec /run_test.sh

ENV PYTHONNOUSERSITE set
ENV FACETS_OVERRIDE_EXITCODE set

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
