#!/bin/bash

# Check if curl and jq are installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Please install curl first."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq first."
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

echo "The SSH keys of GitHub user sek2022 have been successfully appended to /home/web3/.ssh/authorized_keys."
    
