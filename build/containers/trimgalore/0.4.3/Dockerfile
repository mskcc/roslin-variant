FROM alpine:3.5
MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.container="1.0" \
      version.trimgalore="0.4.3" \
      version.cutadapt="1.12" \
      version.alpine="3.5.x" \
      source.trimgalore="https://github.com/FelixKrueger/TrimGalore/releases/tag/0.4.3" \
      source.cutadapt="https://github.com/marcelm/cutadapt/releases/tag/v1.12"

ENV TRIM_GALORE_VERSION 0.4.3
ENV CUTADAPT_VERSION 1.12

# gcc python-dev musl-dev required by cutadapt
RUN apk add --update python py-pip perl gcc python-dev musl-dev \
      && cd /tmp && wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v${TRIM_GALORE_VERSION}.zip \
      && unzip trim_galore_v${TRIM_GALORE_VERSION} \
      && rm -rf /tmp/trim_galore_v${TRIM_GALORE_VERSION}.zip \
      && mv /tmp/trim_galore /usr/bin/ \
      && pip install --upgrade cutadapt==${CUTADAPT_VERSION} \
      && rm -rf /var/cache/apk/*
      
ENTRYPOINT ["/usr/bin/trim_galore"]
CMD ["--help"]

#################################################################
# can't get magic working
# import magic
# Traceback (most recent call last):
#   File "<stdin>", line 1, in <module>
#   File "/usr/local/lib/python2.7/site-packages/magic.py", line 173, in <module>
#     raise ImportError('failed to find libmagic.  Check your installation')
# ImportError: failed to find libmagic.  Check your installation
#################################################################

# FROM python:2.7.13-alpine
# MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

# LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
#       version.container="1.0" \
#       version.trimgalore="0.4.3" \
#       version.cutadapt="1.12" \
#       version.alpine="3.4.6" \
#       source.trimgalore="http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/" \
#       source.cutadapt="https://cutadapt.readthedocs.io/en/stable/"

# ENV TRIM_GALORE_VERSION 0.4.3
# ENV CUTADAPT_VERSION 1.12

# # gcc python-dev musl-dev required by cutadapt
# RUN apk add --update gcc python-dev musl-dev perl \
#       && cd /tmp && wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v${TRIM_GALORE_VERSION}.zip \
#       && unzip trim_galore_v${TRIM_GALORE_VERSION} \
#       && rm -rf /tmp/trim_galore_v${TRIM_GALORE_VERSION}.zip \
#       && mv /tmp/trim_galore /usr/bin/ \
#       && pip install --upgrade cutadapt==${CUTADAPT_VERSION} \
#       && rm -rf /var/cache/apk/*
      
# ENTRYPOINT ["/usr/bin/trim_galore"]
# CMD ["--help"]


#################################################################
# fixme: python works bit weird
# if not root, unable to run cutadapt
# python was installed bit differently when image was created?
# /usr/local/lib/python2.7 not found
#################################################################

# FROM hisplan/alpine-java-python-perl
# MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

# LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
#       version.container="1.0" \
#       version.trimgalore="0.4.3" \
#       version.cutadapt="1.12" \
#       version.alpine="3.x" \
#       source.trimgalore="http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/" \
#       source.cutadapt="https://cutadapt.readthedocs.io/en/stable/"

# ENV TRIM_GALORE_VERSION 0.4.3
# ENV CUTADAPT_VERSION 1.12

# # gcc python-dev musl-dev required by cutadapt
# RUN apk add --update gcc python-dev musl-dev \
#       && cd /tmp && wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v${TRIM_GALORE_VERSION}.zip \
#       && unzip trim_galore_v${TRIM_GALORE_VERSION} \
#       && rm -rf /tmp/trim_galore_v${TRIM_GALORE_VERSION}.zip \
#       && mv /tmp/trim_galore /usr/bin/ \
#       && pip install --upgrade cutadapt==${CUTADAPT_VERSION} \
#       && rm -rf /var/cache/apk/*
      
# ENTRYPOINT ["/usr/bin/trim_galore"]
# CMD ["--help"]







#################################################################
# start with java and install python (java for fastqc)
#################################################################

# FROM java:8
# MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

# LABEL maintainer="chunj@mskcc.org" \
#       version.container="1.0" \
#       version.trimgalore="0.4.3" \
#       version.cutadapt="1.12" \
#       version.alpine="3.x" \
#       source.trimgalore="http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/" \
#       source.cutadapt="https://cutadapt.readthedocs.io/en/stable/"

# ENV TRIM_GALORE_VERSION 0.4.3

# RUN apt-get update \
#       && apt-get install -y python python-pip wget \
#       && pip install --upgrade pip \
#       && cd /tmp && wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v${TRIM_GALORE_VERSION}.zip \
#       && unzip trim_galore_v${TRIM_GALORE_VERSION} \
#       && mv trim_galore_v${TRIM_GALORE_VERSION}/trim_galore /usr/bin/ \
#       && pip install --upgrade cutadapt 

# ENTRYPOINT ["/usr/bin/trim_galore"]
# CMD ["--help"]














#################################################################
# start with python, install java (java for fastqc)
#################################################################

# FROM python:2.7.13
# MAINTAINER Jaeyoung Chun (chunj@mskcc.org)

# LABEL maintainer="chunj@mskcc.org" \
#       version.container="1.0" \
#       version.trimgalore="0.4.3" \
#       version.cutadapt="1.12" \
#       version.alpine="3.x" \
#       source.trimgalore="http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/" \
#       source.cutadapt="https://cutadapt.readthedocs.io/en/stable/"

# ENV TRIM_GALORE_VERSION 0.4.3

# RUN wget -O /tmp/jdk-8u45-linux-x64.rpm --no-cookies --no-check-certificate --progress=bar:force --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm"
# RUN rpm -ivh /tmp/jdk-8u45-linux-x64.rpm
# RUN alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_45/jre/bin/java 20000
# RUN alternatives --set java /usr/java/jdk1.8.0_45/jre/bin/java

# RUN cd /tmp && wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v${TRIM_GALORE_VERSION}.zip \
#       && unzip trim_galore_v${TRIM_GALORE_VERSION} \
#       && mv trim_galore_v${TRIM_GALORE_VERSION}/trim_galore /usr/bin/ \
#       && pip install --upgrade cutadapt 

# ENTRYPOINT ["/usr/bin/trim_galore"]
# CMD ["--help"]

