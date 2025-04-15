#!/bin/bash

# 获取 CPU 核数
cpu_cores=$(lscpu | grep "Core(s) per socket:" | awk '{print $NF}')
echo "CPU 核数: $cpu_cores"

# 获取 CPU 线程数
cpu_threads=$(lscpu | grep "Thread(s) per core:" | awk '{print $NF}')
echo "CPU 线程数: $cpu_threads"

# 获取内存大小
total_memory=$(free -h | grep "Mem:" | awk '{print $2}')
echo "内存大小: $total_memory"

# 获取显卡型号
gpu_info=$(lspci | grep -i "VGA" | awk -F ':' '{print $3}' | sed 's/^ //')
if [ -z "$gpu_info" ]; then
    echo "未检测到显卡信息"
else
    echo "显卡型号: $gpu_info"
fi    
