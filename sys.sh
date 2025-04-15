#!/bin/bash

# 获取物理 CPU 数量
physical_cpus=$(lscpu | grep "Socket(s):" | awk '{print $2}')
# 获取每个 CPU 的核心数
cores_per_cpu=$(lscpu | grep "Core(s) per socket:" | awk '{print $NF}')

# 计算总的物理 CPU 核心数
total_cpu_cores=$((physical_cpus * cores_per_cpu))
echo "CPU 核数: $total_cpu_cores"

# 从 /proc/cpuinfo 中获取线程数
threads=$(grep 'processor' /proc/cpuinfo | wc -l)
echo "CPU 线程数: $threads"

# 获取内存大小
total_memory=$(free -h | grep "Mem:" | awk '{print $2}')
if [ -z "$total_memory" ]; then
    echo "无法获取内存大小信息"
    exit 1
fi
echo "内存大小: $total_memory"

# 获取显卡型号
gpu_info=$(lspci | grep -i "VGA" | awk -F ':' '{print $3}' | sed 's/^ //')
if [ -z "$gpu_info" ]; then
    echo "未检测到显卡信息"
else
    echo "显卡型号: $gpu_info"
fi
