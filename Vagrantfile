# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  required_plugins = %w( vagrant-disksize )
    required_plugins.each do |plugin|
        unless Vagrant.has_plugin? plugin
            system "vagrant plugin install #{plugin}"
            exec "vagrant #{ARGV.join' '}"
        end
    end

  config.vm.box = "bento/ubuntu-16.04"
  config.disksize.size = '50GB'

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.memory = "2048"
	end

  config.vm.hostname = "roslin-variant"
  config.vm.provision "shell", path: "./vm/resize-disk.sh"
  config.vm.provision "shell", path: "./vm/bootstrap.sh"
  config.vm.provision "shell", path: "./vm/install-python.sh"
  config.vm.provision "shell", path: "./vm/install-singularity.sh"
  config.vm.provision "shell", path: "./vm/install-docker.sh"
  config.vm.provision "shell", path: "./vm/install-docker-registry.sh"
  config.vm.provision "shell", path: "./vm/install-cmo.sh", privileged: false
end
