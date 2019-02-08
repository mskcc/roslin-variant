sudo parted --script /dev/sda mkpart primary 42.9G 100%
sudo parted --script /dev/sda set 3 lvm on
sudo pvcreate /dev/sda3
sudo vgextend vagrant-vg /dev/sda3
sudo lvextend /dev/mapper/vagrant--vg-root -rl +100%FREE

