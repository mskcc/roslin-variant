#!/bin/bash
ID=$1
# Create log directory
mkdir -p /vagrant/test_output
TestDir=/vagrant/test_output/$ID
mkdir $TestDir
# using highly advance communication let jenkins know that build failed
function on_exit {
 cd $TestDir
 touch EXIT
}
trap on_exit ERR
# Dynamically edit config and set it
cp /vagrant/test/config.test.yaml.template $TestDir/config.test.yaml
sed -i "s/BUILD_VALUE/$ID/g" $TestDir/config.test.yaml
/vagrant/configure.py $TestDir/config.test.yaml
# build images and cwl
cd /vagrant/build/scripts
./build-all.sh > $TestDir/build_stdout.txt 2> $TestDir/build_stderr.txt
# move everything to setup
cd /vagrant/build/scripts
./move-all-artifacts-to-setup.sh > $TestDir/move_stdout.txt 2> $TestDir/move_stderr.txt
# check if cwls are generated
if [ $(ls | grep -c "error.*") -gt 0 ]
then
cp error.* $TestDir
on_exit
fi

