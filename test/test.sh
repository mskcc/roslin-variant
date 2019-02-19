#/bin/bash
set -e

usage()
{
cat << EOF
USAGE: `basename $0` [options]
OPTIONS:
   -s      Run first time setup
   -w      Workflow filename (*.cwl)
   -n      Run outside the vagrant container
EXAMPLE:
   `basename $0` -s -w project-workflow.cwl
   `basename $0` -w project-workflow-sv.cwl
EOF
}

while getopts “snw:” OPTION
do
    case $OPTION in
    	s) setup=true ;;
		n) baseDir=$(pwd) ;;
    	w) workflow_filename=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done
if [ -z "$workflow_filename" ] ; then
	usage
	exit 1
fi

if [ -z "$baseDir" ] ; then
	baseDir=/vagrant
fi
export ROSLIN_ROOT=$baseDir
cd $baseDir/core
python configure.py config.core.yaml
cd $baseDir
python configure.py config.variant.yaml
sed -i "s/\${ROSLIN_PIPELINE_ROOT}\/bin/\$baseDir\/setup/g" setup/config/settings.sh

if [ "$setup" = true ] ; then
	cd ~
	cd $baseDir/core/bin/install
	./install-core.sh
	cd $baseDir
	mkdir -p $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION
	cp setup/config/settings.sh $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION
	cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION
	if [ ! -f virtualenv/bin/activate ]; then
		virtualenv virtualenv
	fi
	source virtualenv/bin/activate
	export PATH=$ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/virtualenv/bin/:$PATH
	cd $parentDir
	pip install -r /vagrant/build/run_requirements.txt
	# install toil
	rsync -a --exclude="$ROSLIN_TOIL_INSTALL_PATH/.git/*" $ROSLIN_TOIL_INSTALL_PATH $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/toil
	cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/toil
	make prepare
	make develop extras=[cwl]
	# install cmo
	rsync -a --exclude="$ROSLIN_CMO_INSTALL_PATH/.git/*" $ROSLIN_CMO_INSTALL_PATH $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/cmo
	cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/cmo
	python setup.py install
	mkdir -p $baseDir/setup/scripts/
	mkdir -p $baseDir/setup/tmp/
	yes | cp $baseDir/setup/bin/* $baseDir/setup/scripts/
	deactivate
	# Setup node
	HOME_TEMP=$HOME
	export HOME=$ROSLIN_PIPELINE_DATA_PATH
	if [ ! -f virtualenv/bin/activate ]; then
		mkdir .nvm
		curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	fi
	[ -s "$ROSLIN_PIPELINE_DATA_PATH/.nvm/nvm.sh" ] && \. "$ROSLIN_PIPELINE_DATA_PATH/.nvm/nvm.sh"
	nvm install node
	export HOME=$HOME_TEMP
	cd $ROSLIN_CORE_BIN_PATH
	sed -i "s/48G/15G/g" roslin-runner.sh
	sed -i "s/14/8/g" roslin-runner.sh
fi

source $baseDir/core/config/settings.sh
source $baseDir/setup/config/settings.sh

[ -s "$ROSLIN_PIPELINE_DATA_PATH/.nvm/nvm.sh" ] && \. "$ROSLIN_PIPELINE_DATA_PATH/.nvm/nvm.sh"

cd $baseDir/setup/examples/Proj_DEV_0003/

roslin_request_to_yaml.py \
    --pipeline $ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION \
    -m Proj_DEV_0003_sample_mapping.txt \
    -p Proj_DEV_0003_sample_pairing.txt \
    -g Proj_DEV_0003_sample_grouping.txt \
    -r Proj_DEV_0003_request.txt \
    -o . \
    -f inputs.yaml

if [ -d $baseDir/setup/examples/Proj_DEV_0003/outputs ]; then
	rm -r $baseDir/setup/examples/Proj_DEV_0003/outputs
fi
roslin-runner.sh -v $ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION -w $workflow_filename -i inputs.yaml -b singleMachine