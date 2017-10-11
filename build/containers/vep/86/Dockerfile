FROM alpine:3.4

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.image="1.0.0" \
      version.vep="86" \
      version.htslib="1.4" \
      version.perl="5.22.2-r0" \
      version.alpine="3.4.x" \
      source.vep="http://dec2016.archive.ensembl.org/info/docs/tools/vep/script/vep_download.html#versions" \
      source.htslib="https://github.com/samtools/htslib/releases/tag/1.4"

ENV VEP_VERSION 86
ENV PERL_VERSION 5.22.2-r0
ENV HTSLIB_VERSION 1.4

# http://www.ensembl.org/info/docs/tools/vep/script/vep_tutorial.html

RUN apk add --update \
      && apk add ca-certificates openssl gcc g++ make git curl curl-dev wget gzip perl=${PERL_VERSION} musl-dev libgcrypt-dev perl-dev zlib-dev bzip2-dev xz-dev ncurses-dev \
      # install cpanminus
            && curl -L https://cpanmin.us | perl - App::cpanminus \
      # install htslib (for vep)
            && cd /tmp && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
            && tar xvjf htslib-${HTSLIB_VERSION}.tar.bz2 \
            && cd /tmp/htslib-${HTSLIB_VERSION} \
            && ./configure \
            && make && make install \
      # download/unzip vep
            && cd /tmp && wget https://github.com/Ensembl/ensembl-tools/archive/release/${VEP_VERSION}.zip \
            && unzip ${VEP_VERSION} \
      # install perl libs
            && cpanm File::Copy::Recursive \
            Archive::Extract \
            Archive::Zip \
            Bio::Root::Version \
            DBI \
            CGI \
            Sereal \
            # optional
            JSON \
            Set::IntervalTree \
            PerlIO::gzip \
            # optional, but couldn't get it to work
            # DBD::mysql
            # Bio::DB::BigFile
            # LWP::Simple
      # install vep
            && cd /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor \
            && perl INSTALL.pl --AUTO a 2>&1 | tee install.log \
            && cd /tmp && mv /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor /usr/bin/vep \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/*
            
ENTRYPOINT ["perl", "/usr/bin/vep/variant_effect_predictor.pl"]
CMD ["--help"]
