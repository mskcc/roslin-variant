# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-16.04"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.memory = "2048"
	end

  config.vm.hostname = "roslin-variants"

  config.vm.provision "shell", path: "./vm/bootstrap.sh"
  config.vm.provision "shell", path: "./vm/install-python.sh"
  config.vm.provision "shell", path: "./vm/install-singularity.sh"
  config.vm.provision "shell", path: "./vm/install-docker.sh"
  config.vm.provision "shell", path: "./vm/install-docker-registry.sh"
end
