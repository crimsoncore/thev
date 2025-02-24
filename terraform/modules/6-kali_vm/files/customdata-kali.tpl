#cloud-config
runcmd:
  - sudo sysctl -w vm.max_map_count=262144
  - sudo pip3 install updog
  - sudo echo vm.max_map_count=262144 >> /etc/sysctl.conf
