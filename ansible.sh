#!/bin/bash

set -e

echo "[INFO] Detecting OS..."
# Detect OS
if [ -f /etc/debian_version ]; then
    OS="debian"
elif [ -f /etc/redhat-release ]; then
    OS="rhel"
else
    echo "[ERROR] Unsupported OS."
    exit 1
fi

echo "[INFO] Installing prerequisites..."
if [ "$OS" = "debian" ]; then
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
elif [ "$OS" = "rhel" ]; then
    sudo yum install -y epel-release
    sudo yum install -y python3 python3-pip
    sudo yum install -y ansible
fi

echo "[INFO] Installing pip requirements..."
# Example pip requirements
# Create a virtual environment (optional but recommended)
python3 -m venv ~/.ansible-venv
source ~/.ansible-venv/bin/activate

# Install additional pip packages used with Ansible
pip install --upgrade pip
pip install boto boto3 botocore requests

# Deactivate virtualenv after installation
deactivate

echo "[INFO] Ansible and pip requirements installed successfully."

echo "[INFO] Copying ssh keys and running Ansible playbook."
mkdir -p /home/vagrant/worker1_key
mkdir -p /home/vagrant/worker2_key
cp /vagrant/.vagrant/machines/worker1/virtualbox/private_key /home/vagrant/worker1_key/private_key 
cp /vagrant/.vagrant/machines/worker2/virtualbox/private_key  /home/vagrant/worker2_key/private_key 
chmod 600 /home/vagrant/worker1_key/private_key
chmod 600 /home/vagrant/worker2_key/private_key
rm -rf /tmp/provisioning
cp -r /vagrant/ansible /tmp/provisioning
cd /tmp/provisioning
chmod -x inventory.ini
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook playbook.yml --inventory-file=inventory.ini
