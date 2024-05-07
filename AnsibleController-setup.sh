#!/bin/bash

# Update package manager repositories and install Ansible
sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

# Uncomment necessary lines in sshd_config
sudo sed -i '/#PubkeyAuthentication/s/^#//g' /etc/ssh/sshd_config
sudo sed -i '/#PasswordAuthentication/s/^#//g' /etc/ssh/sshd_config

# Edit sudoers file
echo '%ansiuser ALL=NOPASSWD: ALL' | sudo tee -a /etc/sudoers > /dev/null

# Restart SSH service
sudo service ssh restart

# Add a new user named "ansiuser" using useradd
sudo useradd -m -s /bin/bash ansiuser

# Change ownership recursively of /etc/ansible to the new user
sudo chown -R ansiuser /etc/ansible

# Switch to the newly created user and generate SSH key pair
sudo su - ansiuser -c "
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N \"\"
    cat ~/.ssh/id_rsa.pub
"
