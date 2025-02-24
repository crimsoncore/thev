#cloud-config

package_update: true
package_upgrade: true
package_reboot_if_required: true

groups:
    - ubuntu
    - docker
sudo:
    - ALL=(ALL) NOPASSWD:ALL
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - git
runcmd:
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update -y
  - apt-get install -y docker-ce docker-ce-cli containerd.io
  - apt-get install -y docker-compose
  - systemctl start docker
  - systemctl enable docker
  - sudo sysctl -w vm.max_map_count=262144
  - cd /opt
  - git clone https://github.com/crimsoncore/threathunt.git
  - cd /opt/threathunt
  - docker-compose -f dc.rabbitmq.yml up -d
  - sudo echo vm.max_map_count=262144 >> /etc/sysctl.conf
final_message: "The system is finally up, after $UPTIME seconds"