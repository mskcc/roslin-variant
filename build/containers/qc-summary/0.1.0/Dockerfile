FROM rocker/r-ver:3.5.1

LABEL maintainer="C. Allan Bolipata (bolipatc@mskcc.org)" \
      version.image="0.1" \
      version.roslin-qc="0.6.0" \
      version.rocker="3.5.1" \
      source.roslin-qc="https://github.com/mskcc/roslin-qc/tree/master"

ENV ROSLIN_QC_VERSION 0.6.0
ENV ROCKER_VERSION 3.5.1

ENV PATH "$PATH:/bin"

COPY runscript.sh /usr/bin/runscript.sh
COPY run_test.sh /run_test.sh

RUN apt -y update && apt -y install git perl build-essential python libudunits2-dev \
    && cd /tmp \
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

ENTRYPOINT ["sh","/usr/bin/runscript.sh"]
CMD ["help"]
