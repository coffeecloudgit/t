#!/bin/bash

# Update package list and install jq
sudo apt-get update -y
sudo apt-get install -y jq

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Please install curl first."
    exit 1
fi

# Create user web3
useradd -m -s /bin/bash web3

# Set the password for user web3
echo "Please set the password for user web3:"
passwd web3

# Create the .ssh directory
sudo -u web3 mkdir -p /home/web3/.ssh

# Create the authorized_keys file
sudo -u web3 touch /home/web3/.ssh/authorized_keys

# Set permissions for the .ssh directory and authorized_keys file
chmod 700 /home/web3/.ssh
chmod 600 /home/web3/.ssh/authorized_keys

# Send a request to get the SSH key list
GITHUB_USERNAME="sek2022"
KEYS=$(curl -s https://api.github.com/users/$GITHUB_USERNAME/keys)

# Check if the data was successfully retrieved
if [[ -z "$KEYS" ]]; then
    echo "Failed to retrieve the SSH key list from GitHub. Please check the network or the GitHub username."
    exit 1
fi

# Extract each SSH key and append it to the authorized_keys file
echo "$KEYS" | jq -r '.[].key' | sudo -u web3 tee -a /home/web3/.ssh/authorized_keys > /dev/null

# Get the internal IP starting with 10.40
INTERNAL_IP=$(ip addr show | grep 'inet 10.40' | awk '{print $2}' | cut -d/ -f1)

if [ -z "$INTERNAL_IP" ]; then
    echo "No internal IP starting with 10.40 was found."
    exit 1
fi

# Replace dots with hyphens in the IP address
MODIFIED_IP=$(echo $INTERNAL_IP | tr '.' '-')

# Update the /etc/hostname file
NEW_HOSTNAME="web3-$MODIFIED_IP"
echo $NEW_HOSTNAME | sudo tee /etc/hostname > /dev/null

# Apply the new hostname
sudo hostnamectl set-hostname $NEW_HOSTNAME

echo "The SSH keys of GitHub user sek2022 have been successfully appended to /home/web3/.ssh/authorized_keys."
echo "The hostname has been updated to $NEW_HOSTNAME."
    
