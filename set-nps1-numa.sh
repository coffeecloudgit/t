#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 权限运行此脚本。"
    exit 1
fi

# 备份原始的 GRUB 配置文件
cp /etc/default/grub /etc/default/grub.bak
echo "已备份原始的 GRUB 配置文件到 /etc/default/grub.bak"

# 检查 GRUB_CMDLINE_LINUX 参数是否存在 numa=nps1
if grep -q "numa=nps1" /etc/default/grub; then
    echo "GRUB 配置中已经包含 'numa=nps1'，无需修改。"
else
    # 查找 GRUB_CMDLINE_LINUX 参数并添加 numa=nps1
    if grep -q "GRUB_CMDLINE_LINUX=" /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1numa=nps1"/' /etc/default/grub
    else
        echo 'GRUB_CMDLINE_LINUX="numa=nps1"' >> /etc/default/grub
    fi
    echo "已在 GRUB 配置中添加 'numa=nps1'"
fi

# 更新 GRUB 配置
update-grub
echo "已更新 GRUB 配置"

# 询问是否重启服务器
read -p "是否要重启服务器以应用新的配置？(y/n): " answer
case $answer in
    [Yy]* )
        if ! command -v ipmitool &> /dev/null; then
            echo "ipmitool 未安装，正在安装..."
            apt-get update
            apt-get install -y ipmitool
            if [ $? -eq 0 ]; then
                echo "ipmitool 安装成功，正在使用 ipmitool 重启服务器..."
                ipmitool power reset
            else
                echo "ipmitool 安装失败，你可以手动尝试安装后再使用 'ipmitool power reset' 重启服务器。"
            fi
        else
            echo "正在使用 ipmitool 重启服务器..."
            ipmitool power reset
        fi
        ;;
    [Nn]* )
        echo "未进行重启操作。若之后需要重启，请手动运行 'ipmitool power reset' 或 'sudo reboot'。"
        ;;
    * )
        echo "输入无效，请输入 'y' 或 'n'。"
        ;;
esac
