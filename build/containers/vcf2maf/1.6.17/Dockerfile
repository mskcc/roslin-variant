FROM alpine:3.8

LABEL maintainer="Christopher Allan Bolipata (bolipatc@mskcc.org)" \
      contributor="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.vcf2maf="1.6.17" \
      version.vep="86" \
      version.htslib="1.9" \
      version.bcftools="1.9" \
      version.samtools="1.9" \
      version.perl="5.26.2-r1" \
      version.alpine="3.8" \
      source.vcf2maf="https://github.com/mskcc/vcf2maf/releases/tag/v1.6.17" \
      source.vep="http://dec2016.archive.ensembl.org/info/docs/tools/vep/script/vep_download.html#versions" \
      source.vep_cache="ftp.ensembl.org/ensembl/pub/release-86/variation/VEP/homo_sapiens_vep_86_GRCh37.tar.gz" \
      source.htslib="https://github.com/samtools/htslib/releases/tag/1.9" \
      source.bcftools="https://github.com/samtools/bcftools/releases/tag/1.9" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/1.9"

ENV VCF2MAF_VERSION 1.6.17
ENV VEP_VERSION 86
ENV VEP_DATA /var/cache
ENV VEP_PATH /usr/bin/vep
ENV HTSLIB_VERSION 1.9
ENV SAMTOOLS_VERSION 1.9
ENV BCFTOOLS_VERSION 1.9

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

RUN apk add --update \
      # install all the build-related tools
            && apk add ca-certificates gcc g++ make git curl curl-dev wget gzip perl perl-dev musl-dev libgcrypt-dev zlib-dev bzip2-dev xz-dev ncurses-dev rsync \
      # install system packages and Perl modules
            && apk add expat-dev libressl-dev perl-net-ssleay mariadb-dev libxml2-dev perl-dbd-mysql perl-module-metadata perl-gd perl-db_file perl-archive-zip perl-cgi perl-dbi perl-encode perl-time-hires perl-file-copy-recursive perl-json \
      # install cpanminus
            && curl -L https://cpanmin.us | perl - App::cpanminus \
      # install perl libraries that VEP will need
            && cpanm --notest LWP LWP::Simple LWP::Protocol::https Archive::Extract Archive::Tar Archive::Zip \
            CGI DBI Encode version Time::HiRes File::Copy::Recursive Perl::OSType Module::Metadata \
            Sereal JSON Bio::Root::Version Set::IntervalTree PerlIO::gzip \
      # install htslib (for vep)
            && cd /tmp && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
            && tar xvjf htslib-${HTSLIB_VERSION}.tar.bz2 \
            && cd /tmp/htslib-${HTSLIB_VERSION} \
            && ./configure \
            && make && make install \
      # download/unzip vep
            && cd /tmp && wget https://github.com/Ensembl/ensembl-tools/archive/release/${VEP_VERSION}.zip \
            && unzip ${VEP_VERSION} \
      # install vep
            && cd /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor \
            && perl INSTALL.pl --AUTO a 2>&1 | tee install.log \
            && cd /tmp && mv /tmp/ensembl-tools-release-${VEP_VERSION}/scripts/variant_effect_predictor /usr/bin/vep \
      # download and unpack VEP's offline cache
            && mkdir -p ${VEP_DATA} \
            && rsync -zvh rsync://ftp.ensembl.org/ensembl/pub/release-86/variation/VEP/homo_sapiens_vep_86_GRCh37.tar.gz ${VEP_DATA} \
            && tar -zxf ${VEP_DATA}/homo_sapiens_vep_86_GRCh37.tar.gz -C ${VEP_DATA} \
            && cd /usr/bin/vep \
            && perl convert_cache.pl --species homo_sapiens --version 86_GRCh37 --dir ${VEP_DATA} \
            && rm ${VEP_DATA}/homo_sapiens_vep_86_GRCh37.tar.gz \
      # install bcftools
            && cd /tmp && wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
            && tar xvjf bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
            && cd /tmp/bcftools-${BCFTOOLS_VERSION} \
            && make HTSDIR=/tmp/htslib-${HTSLIB_VERSION} && make install \
      # install samtools
            && cd /tmp && wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
            && tar xvjf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
            && cd /tmp/samtools-${SAMTOOLS_VERSION} \
            && ./configure --with-htslib=/tmp/htslib-${HTSLIB_VERSION} \
            && make && make install \
      # install vcf2maf
            && cd /tmp && wget -O vcf2maf-v${VCF2MAF_VERSION} https://github.com/mskcc/vcf2maf/archive/v${VCF2MAF_VERSION}.zip \
            && unzip vcf2maf-v${VCF2MAF_VERSION} \
            && mkdir -p /usr/bin/vcf2maf/ \
            && cp -r vcf2maf-${VCF2MAF_VERSION}/* /usr/bin/vcf2maf/ \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/* \
            && chmod +x /usr/bin/runscript.sh \
            && exec /run_test.sh
