#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 权限运行此脚本。"
    exit 1
fi

# 备份原始的 GRUB 配置文件
cp /etc/default/grub /etc/default/grub.bak
echo "已备份原始的 GRUB 配置文件到 /etc/default/grub.bak"

# 检查 GRUB_CMDLINE_LINUX 参数是否存在 numa=off
if grep -q "numa=off" /etc/default/grub; then
    echo "GRUB 配置中已经包含 'numa=off'，无需修改。"
else
    # 查找 GRUB_CMDLINE_LINUX 参数并添加 numa=off
    if grep -q "GRUB_CMDLINE_LINUX=" /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 numa=off"/' /etc/default/grub
    else
        echo 'GRUB_CMDLINE_LINUX="numa=off"' >> /etc/default/grub
    fi
    echo "已在 GRUB 配置中添加 'numa=off'"
fi

# 更新 GRUB 配置
update-grub
echo "已更新 GRUB 配置"

# 询问是否重启服务器
read -p "是否要重启服务器以应用新的配置？(y/n): " answer
case $answer in
    [Yy]* )
        if command -v ipmitool &> /dev/null; then
            echo "正在使用 ipmitool 重启服务器..."
            ipmitool power reset
        else
            echo "ipmitool 未安装，无法使用其重启服务器。你可以使用 'sudo reboot' 手动重启。"
        fi
        ;;
    [Nn]* )
        echo "未进行重启操作。若之后需要重启，请手动运行 'ipmitool power reset' 或 'sudo reboot'。"
        ;;
    * )
        echo "输入无效，请输入 'y' 或 'n'。"
        ;;
esac
