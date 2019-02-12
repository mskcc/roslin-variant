# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.define "roslin_vm"
  config.vm.box = "centos/7"

  # Install the sshfs plugin if not already
  unless Vagrant.has_plugin? "vagrant-sshfs"
    system "vagrant plugin install vagrant-sshfs"
    exec "vagrant #{ARGV.join' '}"
  end

  # Use sshfs (instead of rsync) to mount the current working repository
  config.vm.synced_folder ".", "/vagrant", type: "sshfs"

  # Use sshfs to mount the network disks with tools/data that Roslin needs
  config.ssh.forward_agent = 'true'
  config.vm.synced_folder "/opt/common", "/opt/common", type: "sshfs",
    ssh_host: "juno.mskcc.org", ssh_username: "roslin",
    ssh_opts_append: "-o IdentityFile=/vagrant/vm/id_rsa -o Compression=yes -o CompressionLevel=5",
    sshfs_opts_append: "-o auto_cache -o cache_timeout=115200"
  config.vm.synced_folder "/ifs/depot/pi", "/ifs/depot/pi", type: "sshfs",
    ssh_host: "juno.mskcc.org", ssh_username: "roslin",
    ssh_opts_append: "-o IdentityFile=/vagrant/vm/id_rsa -o Compression=yes -o CompressionLevel=5",
    sshfs_opts_append: "-o auto_cache -o cache_timeout=115200"

  # VirtualBox specific configuration options
  config.vm.provider "virtualbox" do |vb|
    vb.name = "roslin_vm"
    vb.cpus = 8
    vb.memory = "16384"
  end

  # Run the script that installs everything we need on this VM
  config.vm.provision "shell", path: "./vm/bootstrap.sh", privileged: false
end
