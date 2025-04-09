#!/bin/bash

# 检查 iperf 是否已经安装
if ! command -v iperf &> /dev/null
then
    echo "iperf is not installed. Starting installation..."
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu 系统
        sudo apt-get update
        sudo apt-get install -y iperf
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL 系统
        sudo yum install -y iperf
    else
        echo "Unsupported operating system. Please install iperf manually."
        exit 1
    fi
fi

# 启动 iperf 服务端
iperf -s    
