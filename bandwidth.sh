#!/bin/bash

# Check if iperf is already installed
if ! command -v iperf &> /dev/null
then
    echo "iperf is not installed. Starting installation..."
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu systems
        sudo apt-get update
        sudo apt-get install -y iperf
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL systems
        sudo yum install -y iperf
    else
        echo "Unsupported operating system. Please install iperf manually."
        exit 1
    fi
fi

# Start the iperf server
iperf -s -D

# Wait for the server to start
sleep 2

# Start the iperf client for bandwidth testing
SERVER_IP="127.0.0.1"  # Please modify this to the actual IP address of the server
RESULT=$(iperf -c $SERVER_IP -t 10)

# Output the test results
echo "Bandwidth test results:"
echo "$RESULT"

# Stop the iperf server
pkill iperf    
