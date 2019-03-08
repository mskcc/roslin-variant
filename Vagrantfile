# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-16.04"

  config.vm.provider "virtualbox" do |v|
    v.cpus = 8
    v.memory = "8192"
    v.customize ["modifyvm", :id, "--nictype1", "virtio" ]
    v.customize ["modifyvm", :id, "--nictype2", "virtio" ]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.hostname = "roslin-variant"
  config.vm.provision "shell", path: "./vm/bootstrap.sh"
  config.vm.provision "shell", path: "./vm/install-python.sh"
  config.vm.provision "shell", path: "./vm/install-singularity.sh"
  config.vm.provision "shell", path: "./vm/install-docker.sh"
  config.vm.provision "shell", path: "./vm/install-docker-registry.sh"
end
