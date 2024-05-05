#!/bin/bash

# Switch to root user
sudo -i <<EOF

# Update package repositories
apt update -y

# Set hostname
hostnamectl set-hostname "kworker-node"

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install Docker
apt install docker.io -y

# Load required kernel modules
modprobe overlay
modprobe br_netfilter
cat <<EOFF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOFF

# Configure sysctl settings for Kubernetes
tee /etc/sysctl.d/kubernetes.conf<<EOFF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOFF

# Apply sysctl settings
sysctl --system

# Install curl
apt install curl -y

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package repositories again
apt update -y 

# Install containerd
apt install -y containerd.io

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml



# Path to the configuration file
config_file="/etc/containerd/config.toml"

sleep 60

# Check if the file exists
if [ -f "$config_file" ]; then
    # Use sed to replace the line with SystemdCgroup = false to SystemdCgroup = true
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$config_file"
    echo "SystemdCgroup set to true in $config_file"
else
    echo "Error: Configuration file $config_file not found."
    exit 1
fi

# Restart containerd
systemctl restart containerd

# Update package repositories
apt-get update

# Install necessary packages for Kubernetes
apt-get install -y apt-transport-https ca-certificates curl gnupg

# Create directory for apt keyrings
mkdir -p -m 755 /etc/apt/keyrings

# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Update package repositories again
apt-get update

# Install Kubernetes components
apt-get install -y kubelet kubeadm kubectl

# Enable kubelet service
systemctl enable kubelet

EOF
