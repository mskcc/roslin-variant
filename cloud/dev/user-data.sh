#!/bin/bash -e

sudo apt-get -y update

# install utilities
sudo apt-get -y install tree jq

# create /scratch directory
sudo mkdir -p /scratch


#!/bin/bash -e

# install python
sudo apt-get install -y python

# install pip
sudo apt-get install -y python-pip
sudo pip install --upgrade pip

#!/bin/bash -e

SINGULARITY_VERSION="2.2.1"
SINGULARITY_INSTALL_TEMP_DIR="/tmp/singularity"

sudo apt-get -y install build-essential autoconf automake libtool debootstrap

mkdir -p ${SINGULARITY_INSTALL_TEMP_DIR} && cd $_

wget --no-check-certificate --content-disposition https://github.com/singularityware/singularity/releases/download/${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz
tar xvzf singularity-${SINGULARITY_VERSION}.tar.gz
rm -rf singularity-${SINGULARITY_VERSION}.tar.gz
cd singularity-${SINGULARITY_VERSION}
./configure --prefix=/usr
make
sudo make install

rm -rf ${SINGULARITY_INSTALL_TEMP_DIR}


#!/bin/bash -e

DOCKER_ENGINE_VERSION="1.13.1-0~ubuntu-xenial"

sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -

apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D

sudo add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"

sudo apt-get -y update

sudo apt-get -y install docker-engine=${DOCKER_ENGINE_VERSION}

sudo apt-cache madison docker-engine



#!/bin/bash -e

cd /tmp/
git clone https://github.com/mskcc/toil.git

cd toil
git checkout 3.8.2msk

sudo python setup.py install --prefix /usr/local
sudo pip install toil[cwl,aws,mesos]
# pip install --install-option="--prefix=/usr/local"  toil[cwl]


#!/bin/bash -e

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs


#!/bin/bash -e

sudo pip install awscli


#!/bin/bash -e

version_file="/var/log/roslin-software-versions.txt"

write()
{
    echo $1 | sudo tee --append ${version_file}
}

# $1 name
# $2 command to run to get version
check()
{
    version=`$2 2>&1`
    write "$1 : $version"
}

sudo rm -rf $version_file

check "python" "python --version"
check "pip" "pip --version"
check "aws" "aws --version"
check "cwltoil" "cwltoil --version"
check "docker" "docker --version"
check "node" "node --version"
check "singularity" "singularity --version"

# cmo works a bit different, so...
# need cmo_resources.json in order to import cmo.
# cmo_version=`CMO_RESOURCE_CONFIG="/usr/local/bin/cmo_resources.json" python -c "import cmo; print cmo.__version__"`
# write "cmo : $cmo_version"


#!/bin/bash

# http://docs.aws.amazon.com/cli/latest/reference/ec2/attach-volume.html
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

instance_id="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"
volume_id="vol-0a7514984507e2b83"

aws ec2 attach-volume --volume-id ${volume_id} --instance-id ${instance_id} --device /dev/sdf

# just mount (as long as new volume already has the file system)
sudo mount /dev/xvdf /ifs
sudo chmod ubuntu /ifs



