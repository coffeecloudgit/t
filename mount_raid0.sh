#!/bin/bash

# 获取 /dev/md0 的 UUID
UUID=$(blkid -s UUID -o value /dev/md0)

if [ -z "$UUID" ]; then
    echo "无法获取 /dev/md0 的 UUID。"
    exit 1
fi

# 挂载点
MOUNT_POINT="/opt/raid0"

# 检查挂载点是否存在，如果不存在则创建
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# 构建 fstab 条目
FSTAB_ENTRY="UUID=$UUID $MOUNT_POINT xfs noatime 0 0"

# 检查 fstab 中是否已经存在该条目
if ! grep -q "$FSTAB_ENTRY" /etc/fstab; then
    # 追加条目到 fstab
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab > /dev/null
    echo "已将挂载信息追加到 /etc/fstab。"
else
    echo "挂载信息已存在于 /etc/fstab 中。"
fi

# 挂载磁盘
sudo mount -a
if [ $? -eq 0 ]; then
    echo "磁盘挂载成功。"
else
    echo "磁盘挂载失败，请检查 /etc/fstab 文件。"
fi    
