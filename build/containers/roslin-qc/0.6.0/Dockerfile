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
        # install R
        && apk add R R-dev \
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
        && R -e "install.packages('corrplot', repos='http://cran.wustl.edu')" \
        && R -e "install.packages(c('ggplot2','gplots','scales','reshape','plyr','RColorBrewer','optparse','ggforce'), repos='http://cran.us.r-project.org')" \
        && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \ 
        # Install perl dependency needed
        && perl -MCPAN -e 'install Tie::IxHash' \
        # clean up
        && rm -rf /tmp/*

ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/generate_pdf.py"]
