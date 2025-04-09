#!/bin/bash

# 检查 iperf3 是否已经安装
if ! command -v iperf3 &> /dev/null
then
    echo "iperf3 is not installed. Starting installation..."
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu 系统
        sudo apt-get update
        sudo apt-get install -y iperf3
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL 系统
        sudo yum install -y iperf3
    else
        echo "Unsupported operating system. Please install iperf3 manually."
        exit 1
    fi
fi

# 启动 iperf3 服务端
iperf3 -s    
