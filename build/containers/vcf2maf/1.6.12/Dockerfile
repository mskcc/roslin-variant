FROM alpine:3.4
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.vcf2maf="1.6.12" \
      version.vep="86" \
      version.htslib="1.4" \
      version.htslib="1.4.1" \
      version.perl="5.22.2-r0" \
      version.alpine="3.4.x" \
      source.vcf2maf="https://github.com/mskcc/vcf2maf/releases/tag/v1.6.12" \
      source.vep="http://dec2016.archive.ensembl.org/info/docs/tools/vep/script/vep_download.html#versions" \
      source.htslib="https://github.com/samtools/htslib/releases/tag/1.4" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/1.4.1"

ENV VCF2MAF_VERSION 1.6.12
ENV VEP_VERSION 86
ENV PERL_VERSION 5.22.2-r0
ENV HTSLIB_VERSION 1.4
ENV SAMTOOLS_VERSION 1.4.1

COPY run.sh /usr/bin/vcf2maf/run.sh

# http://www.ensembl.org/info/docs/tools/vep/script/vep_tutorial.html

RUN apk add --update \
      && apk add ca-certificates openssl gcc g++ make git curl curl-dev wget gzip perl=${PERL_VERSION} musl-dev libgcrypt-dev perl-dev zlib-dev bzip2-dev xz-dev ncurses-dev \
      && curl -L https://cpanmin.us | perl - App::cpanminus \
      && cd /tmp && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
      && tar xvjf htslib-${HTSLIB_VERSION}.tar.bz2 \
      && cd /tmp/htslib-${HTSLIB_VERSION} \
      && ./configure \
      && make && make install \
      && cd /tmp && wget https://github.com/Ensembl/ensembl-tools/archive/release/${VEP_VERSION}.zip \
      && unzip ${VEP_VERSION}

RUN cpanm File::Copy::Recursive \
      Archive::Extract \
      Archive::Zip \
      Bio::Root::Version \
      DBI \
      CGI \
      Sereal \
      # optional
      JSON \
      Set::IntervalTree \
      PerlIO::gzip

      # DBD::mysql
      # Bio::DB::BigFile
      # LWP::Simple

RUN cd /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor \
      && perl INSTALL.pl --AUTO a 2>&1 | tee install.log \
      && cd /tmp && mv /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor /usr/bin/vep

# --NO_HTSLIB cause the following warnings:
# MSG: Switching to using /tmp/ensembl-tools-release-86/scripts/variant_effect_predictor/t/..//t/testdata//vep-cache//homo_sapiens/78_GRCh38/test.fa

RUN cd /tmp && wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
      && tar xvjf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
      && cd /tmp/samtools-${SAMTOOLS_VERSION} \
      && ./configure --with-htslib=/tmp/htslib-${HTSLIB_VERSION} \
      && make && make install

RUN cd /tmp && wget -O vcf2maf-v${VCF2MAF_VERSION} https://github.com/mskcc/vcf2maf/archive/v${VCF2MAF_VERSION}.zip \
      && unzip vcf2maf-v${VCF2MAF_VERSION} \
      && cp -r vcf2maf-${VCF2MAF_VERSION}/* /usr/bin/vcf2maf/

RUN rm -rf /tmp/*

ENTRYPOINT ["sh", "/usr/bin/vcf2maf/run.sh"]
