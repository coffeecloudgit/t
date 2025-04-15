#!/bin/bash

# 函数：获取系统硬件信息
get_system_info() {
    # 获取物理 CPU 数量
    physical_cpus=$(lscpu | grep "Socket(s):" | awk '{print $2}')
    # 获取每个 CPU 的核心数
    cores_per_cpu=$(lscpu | grep "Core(s) per socket:" | awk '{print $NF}')

    # 计算总的物理 CPU 核心数
    total_cpu_cores=$((physical_cpus * cores_per_cpu))
    echo "CPU 核数: $total_cpu_cores"

    # 获取每个核心的线程数
    threads_per_core=$(lscpu | grep "Thread(s) per core:" | awk '{print $NF}')
    if [ -z "$threads_per_core" ]; then
        echo "无法获取每个核心的线程数信息"
        exit 1
    fi

    # 计算总的 CPU 线程数
    total_cpu_threads=$((total_cpu_cores * threads_per_core))
    echo "CPU 线程数: $total_cpu_threads"

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
}

# 检查参数
if [ $# -ne 1 ]; then
    echo "用法: $0 [on|off]"
    exit 1
fi

case $1 in
    on)
        echo "操作前系统硬件信息："
        get_system_info
        echo "正在开启超线程..."
        echo on > /sys/devices/system/cpu/smt/control
        if [ $? -eq 0 ]; then
            echo "超线程已开启。"
            echo "操作后系统硬件信息："
            get_system_info
        else
            echo "开启超线程失败。"
        fi
        ;;
    off)
        echo "操作前系统硬件信息："
        get_system_info
        echo "正在关闭超线程..."
        echo off > /sys/devices/system/cpu/smt/control
        if [ $? -eq 0 ]; then
            echo "超线程已关闭。"
            echo "操作后系统硬件信息："
            get_system_info
        else
            echo "关闭超线程失败。"
        fi
        ;;
    *)
        echo "无效的参数。请使用 'on' 或 'off'。"
        exit 1
        ;;
esac    
