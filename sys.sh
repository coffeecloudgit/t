#!/bin/bash

# 获取总的 CPU 核数
total_cpu_cores=$(lscpu | grep "CPU(s):" | awk '{print $2}')
echo "CPU 核数: $total_cpu_cores"

# 获取总的 CPU 线程数
total_cpu_threads=$(lscpu | grep "Thread(s) per core:" | awk '{threads_per_core = $NF}'; lscpu | grep "CPU(s):" | awk '{total_threads = $2 * threads_per_core} END {print total_threads}')
echo "CPU 线程数: $total_cpu_threads"

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
