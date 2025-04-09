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

# 提示用户输入服务端 IP
read -p "Please enter the server IP address: " SERVER_IP

# 启动 iperf 客户端进行带宽测试
RESULT=$(iperf -c $SERVER_IP -t 10)

# 输出测试结果
echo "Bandwidth test results:"
echo "$RESULT"    
