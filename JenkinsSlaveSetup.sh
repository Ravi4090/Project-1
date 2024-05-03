#!/bin/bash

# Switch to root user
sudo su - <<EOF

# Install OpenJDK 17 JRE
sudo apt install openjdk-17-jre -y

# Install Git
sudo apt install git -y

# Install Maven
sudo apt install maven -y

# Install Docker
sudo apt install docker.io -y

# Create a user named devopsadmin with specified options
useradd devopsadmin -s /bin/bash -m -d /home/devopsadmin

# Switch to devopsadmin and execute commands
su - devopsadmin <<INNER_EOF

# Generate an SSH key for devopsadmin without user interaction
ssh-keygen -t ecdsa -b 521 -N "" -f /home/devopsadmin/.ssh/id_ecdsa

# Navigate to the .ssh directory
cd ~/.ssh

# Append the public key to the authorized_keys file
cat id_ecdsa.pub >> authorized_keys

# Set appropriate permissions on SSH files
chmod 600 /home/devopsadmin/.ssh/*

# Change ownership and permissions on the .ssh directory
chown -R devopsadmin /home/devopsadmin/.ssh
chmod 600 /home/devopsadmin/.ssh/authorized_keys
chmod 700 /home/devopsadmin/.ssh

# Display the private key in blue
echo -e "\e[1;34m ------------- Private key generated successfully ------------------:\e[0m"
cat id_ecdsa

# Exit from devopsadmin user
exit

INNER_EOF

# Add devopsadmin user to the docker group
usermod -aG docker devopsadmin

# Exit from root user
exit

EOF
