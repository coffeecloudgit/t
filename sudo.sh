#!/bin/bash

# 检查是否以 root 用户运行
if [ "$EUID" -ne 0 ]; then
            echo "请以 root 用户运行此脚本。"
                exit 1
fi

# 提示用户输入要添加到 sudoers 的用户名
read -p "请输入要添加到 sudoers 的用户名: " username

# 检查用户是否存在
if ! id "$username" &>/dev/null; then
            echo "用户 $username 不存在。"
                exit 1
fi

# 备份 sudoers 文件
cp /etc/sudoers /etc/sudoers.bak

# 检查 sudoers 文件是否可写
if ! [ -w /etc/sudoers ]; then
            echo "/etc/sudoers 文件不可写，请检查权限。"
                exit 1
fi

# 添加用户到 sudoers 以允许无密码 sudo
echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 检查 sudoers 文件是否有语法错误
visudo -c > /dev/null 2>&1
if [ $? -ne 0 ]; then
            echo "在 /etc/sudoers 文件中添加条目时出现语法错误。"
                echo "恢复到备份文件。"
                    cp /etc/sudoers.bak /etc/sudoers
                        exit 1
fi

echo "用户 $username 现在可以无密码使用 sudo。"
