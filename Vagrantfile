# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-6.9"

  # Install the sshfs plugin if not already
  unless Vagrant.has_plugin? "vagrant-sshfs"
    system "vagrant plugin install vagrant-sshfs"
    exec "vagrant #{ARGV.join' '}"
  end

  # Use sshfs (instead of rsync) to mount the current working repository
  config.vm.synced_folder ".", "/vagrant", type: "sshfs"
  config.vm.synced_folder "/opt/common", "/opt/common", type: "sshfs"
  config.vm.synced_folder "/ifs/depot/pi", "/ifs/depot/pi", type: "sshfs"
  config.vm.synced_folder "/ifs/work/pi", "/ifs/work/pi", type: "sshfs"

  # VirtualBox specific configuration options
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 8
    vb.memory = "102400"
  end

  # Run the script that installs everything we need on this VM
  config.vm.provision "shell", path: "./vm/bootstrap.sh", privileged: false
end
