FROM alpine:3.4
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.vep="86" \
      version.perl="5.22.2-r0" \
      version.alpine="3.4.x" \
      source.vep="http://dec2016.archive.ensembl.org/info/docs/tools/vep/script/vep_download.html#versions"

ENV VEP_VERSION 86
ENV PERL_VERSION 5.22.2-r0

# http://www.ensembl.org/info/docs/tools/vep/script/vep_tutorial.html

RUN apk add --update \
      && apk add ca-certificates openssl gcc g++ make git curl wget gzip perl=${PERL_VERSION} musl-dev libgcrypt-dev perl-dev zlib-dev \
      && curl -L https://cpanmin.us | perl - App::cpanminus \
      && cd /tmp && wget https://github.com/Ensembl/ensembl-tools/archive/release/${VEP_VERSION}.zip \
      && unzip ${VEP_VERSION}
      # && rm -rf /tmp/*

RUN cpanm File::Copy::Recursive \
      Archive::Extract \
      Archive::Zip \
      Bio::Root::Version \
      DBI \
      CGI \
      # optional
      JSON \
      Set::IntervalTree \
      PerlIO::gzip

      # DBD::mysql
      # Bio::DB::BigFile

RUN cd /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor \
      && perl INSTALL.pl --AUTO a

ENTRYPOINT ["/usr/bin/vep"]
CMD ["--help"]
