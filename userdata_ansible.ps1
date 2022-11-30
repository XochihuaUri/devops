#cloud-config
apt:
  preserve_sources_list: true
  sources:
    ansible:
      source: "ppa:ansible/ansible" 
packages:
  - software-properties-common
  - ansible
package_update: true
package_upgrade: true
package_reboot_if_required: true

#runcmd:
  - sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  - sudo python3 get-pip.py
  - sudo python3 -m pip install ansible-core

# installation path
ls /etc/ansible
ls /usr/lib/python3/dist-packages/ansible
# Default configuration disabled
ansible-config init --disabled -t all > ansible.cfg

# List collection and modules
ansible-galaxy collection list
ansible-doc -l
