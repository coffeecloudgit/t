#!/bin/bash

# 检查curl和jq是否安装
if ! command -v curl &> /dev/null; then
    echo "curl未安装，请先安装curl。"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq未安装，请先安装jq。"
    exit 1
fi

# 创建用户web3
useradd -m -s /bin/bash web3

# 设置用户web3的密码
echo "请为用户web3设置密码："
passwd web3

# 创建.ssh目录
sudo -u web3 mkdir -p /home/web3/.ssh

# 创建authorized_keys文件
sudo -u web3 touch /home/web3/.ssh/authorized_keys

# 设置.ssh目录和authorized_keys文件的权限
chmod 700 /home/web3/.ssh
chmod 600 /home/web3/.ssh/authorized_keys

# 发送请求获取SSH Key列表
GITHUB_USERNAME="sek2022"
KEYS=$(curl -s https://api.github.com/users/$GITHUB_USERNAME/keys)

# 检查是否成功获取到数据
if [[ -z "$KEYS" ]]; then
    echo "无法从GitHub获取SSH Key列表，请检查网络或 GitHub 用户名是否存在问题。"
    exit 1
fi

# 提取每个SSH Key并追加到authorized_keys文件
echo "$KEYS" | jq -r '.[].key' | sudo -u web3 tee -a /home/web3/.ssh/authorized_keys > /dev/null

echo "GitHub用户 sek2022 的SSH Key已成功追加到/home/web3/.ssh/authorized_keys文件。"
    
