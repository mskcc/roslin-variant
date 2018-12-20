FROM debian:stretch

LABEL org.label-schema.license="GPL-2.0" \
org.label-schema.vcs-url="https://github.com/rocker-org/rocker-versioned" \
org.label-schema.vendor="Rocker Project" \
maintainer="Carl Boettiger <cboettig@ropensci.org>"

ARG R_VERSION
ARG BUILD_DATE
ENV R_VERSION=${R_VERSION:-3.2.5} \
LC_ALL=en_US.UTF-8 \
LANG=en_US.UTF-8 \
TERM=xterm \
PATH=/usr/lib/ccache:$PATH

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
bash-completion \
ca-certificates \
ccache \
file \
fonts-texgyre \
g++ \
gfortran \
gsfonts \
libblas-dev \
libbz2-1.0 \
libcurl3 \
libicu57 \
libjpeg62-turbo \
libopenblas-dev \
libpangocairo-1.0-0 \
libpcre3 \
libpng16-16 \
libreadline7 \
libtiff5 \
liblzma5 \
locales \
make \
unzip \
zip \
zlib1g \
&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
&& locale-gen en_US.utf8 \
&& /usr/sbin/update-locale LANG=en_US.UTF-8 \
&& BUILDDEPS="curl \
default-jdk \
libbz2-dev \
libcairo2-dev \
libcurl4-openssl-dev \
libpango1.0-dev \
libjpeg-dev \
libicu-dev \
libpcre3-dev \
libpng-dev \
libreadline-dev \
libtiff5-dev \
liblzma-dev \
libx11-dev \
libxt-dev \
perl \
rsync \
subversion tcl8.6-dev \
tk8.6-dev \
texinfo \
texlive-extra-utils \
texlive-fonts-recommended \
texlive-fonts-extra \
texlive-latex-recommended \
x11proto-core-dev \
xauth \
xfonts-base \
xvfb \
zlib1g-dev" \
&& apt-get install -y --no-install-recommends $BUILDDEPS \
&& cd tmp/ \
## Download source code
 && svn co https://svn.r-project.org/R/trunk R-devel \
## Extract source code
&& cd R-devel \
## Get source code of recommended packages
&& ./tools/rsync-recommended \
## Set compiler flags
&& R_PAPERSIZE=letter \
R_BATCHSAVE="--no-save --no-restore" \
R_BROWSER=xdg-open \
PAGER=/usr/bin/pager \
PERL=/usr/bin/perl \
R_UNZIPCMD=/usr/bin/unzip \
R_ZIPCMD=/usr/bin/zip \
R_PRINTCMD=/usr/bin/lpr \
LIBnn=lib \
AWK=/usr/bin/awk \
CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
## Configure options
./configure --enable-R-shlib \
--enable-memory-profiling \
--with-readline \
--with-blas \
--with-tcltk \
--disable-nls \
--with-recommended-packages \
## Build and install
&& make \
&& make install \
## Add a default CRAN mirror
&& echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
## Add a library directory (for user-installed packages)
&& mkdir -p /usr/local/lib/R/site-library \
&& chown root:staff /usr/local/lib/R/site-library \
&& chmod g+wx /usr/local/lib/R/site-library \
## Fix library path
&& echo "R_LIBS_USER='/usr/local/lib/R/site-library'" >> /usr/local/lib/R/etc/Renviron \
&& echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
## install packages from date-locked MRAN snapshot of CRAN
&& [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true \
&& MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} \
&& echo MRAN=$MRAN >> /etc/environment \
&& export MRAN=$MRAN \
## MRAN becomes default only in versioned images
## Use littler installation scripts
&& Rscript -e "install.packages(c('littler', 'docopt'), repo = '$MRAN')" \
&& ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
&& ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
&& ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
## TEMPORARY WORKAROUND to get more robust error handling for install2.r prior to littler update
&& curl -O /usr/local/bin/install2.r https://github.com/eddelbuettel/littler/raw/master/inst/examples/install2.r \
&& chmod +x /usr/local/bin/install2.r \
## Clean up from R source install
&& cd / \
&& rm -rf /tmp/* \
&& apt-get remove --purge -y $BUILDDEPS \
&& apt-get autoremove -y \
&& apt-get autoclean -y \
&& rm -rf /var/lib/apt/lists/* \
&& ccache -C 

FROM rocker/r-ver:3.2.5

RUN R -e "install.packages('corrplot', repos='http://cran.wustl.edu')"
RUN R -e "install.packages(c('ggplot2','gplots','scales','reshape','plyr','RColorBrewer','optparse'), repos='http://cran.us.r-project.org')"

FROM alpine:3.8

LABEL maintainer="Nikhil Kumar (kumarn1@mskcc.org)" \
      version.image="1.0.0" \
      version.roslin-qc="0.6.0" \
      version.alpine="3.8" \
      source.roslin-qc="https://github.com/mskcc/roslin-qc/tree/master" \
      source.r="https://pkgs.alpinelinux.org/package/edge/community/x86/R"

ENV ROSLIN_QC_VERSION 0.6.0

RUN apk add --update \
    # for wget
    && apk add ca-certificates openssl \
    # for compilation
    && apk add build-base musl-dev python py-pip python-dev py-setuptools git \
    && cd /tmp \
        # install mysql connector
        && pip install mysql-connector==2.1.4 \
        # install texlive
        && apk add texlive \
        # install texmf-dist
        && apk add texmf-dist \
        # install texmf-dist-latexextra
        && apk add texmf-dist-latexextra \
        # install pandas
        && pip install django==1.11 \
        && pip install dbconfig \
        && pip install pandas \
        # install pylatex
        && pip install pylatex \
        # install python dependencies
        && pip install fnmatch2 argparse \
        # install java and perl
        && apk add openjdk8-jre-base perl \
        # copy current roslin-qc
        && git clone https://github.com/mskcc/roslin-qc.git \
        && cp -R roslin-qc/* /usr/bin/ \
        # FIX ALL THESE WRONG FILE PATHS
        && cd /usr/bin/ \
        && sed -i "s/opt\/common\/CentOS_6-dev\//usr\//g" *.pl \
        && sed -i "s/opt\/common\/CentOS_6\/R\/R-3.2.0\//usr\//g" *.R \
        # Install perl dependency needed
        && perl -MCPAN -e 'install Tie::IxHash' \
        # clean up
        && rm -rf /tmp/*

ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/generate_pdf.py"]
