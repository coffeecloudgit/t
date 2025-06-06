#!/bin/bash

#使用说明，用来提示输入参数
usage() {
 echo "Usage: bash auto-disk.sh [batchMount | saveSerial | batchRm]"
 exit 1
}

batchRm(){
  for disk in $(parted -l |grep 'Disk /dev/sd' |grep Disk |grep TB |awk '{split($2,s,":"); print s[1]}')
  do
    dirName=${disk:5}
    umount /mnt/$dirName
    #4.对磁盘/dev/sd*进行分区
    parted -s "$disk" mklabel gpt
    parted -s "$disk" rm 1
  done
  echo "rm all parted success"
}

batchMount(){
  batchSuccess=true
  for disk in $(parted -l |grep 'Disk /dev/sd' |grep Disk |grep TB |awk '{split($2,s,":"); print s[1]}')
  do
    dirName=${disk:5}
    #4.对磁盘/dev/sd*进行分区
    parted -s "$disk" mklabel gpt
    #5.对磁盘/dev/sd* 指定分区类型和容量占比 mkpart primary 4096s 100%
    parted -s "$disk" mkpart primary 4096s 100%
    sleep 1s
    #6.格式化磁盘/dev/sd*
    mkfs.xfs -f "${disk}"1
    echo -e "/n/n****************$disk parted was Finished! Waiting For 1 second****/n/n"
    sleep 1s
    #7.创建对应磁盘个数的目录，/hadoop*,创建挂载点
    mkdir -p /mnt/"${dirName}"
    #9.通过blk id命令查看磁盘的uuid，获取uuid值
    uuid=$(blkid "${disk}"1 |awk '{print $2}' |sed s#\"##g)
     if [ -z "${uuid}" ]; then
       batchSuccess=false
       echo "$disk uuid not found, batch mount fail!"
       break
     fi
    #10.设置开机自动挂载磁盘，追加uuid信息到 /etc/fstab中。
    echo "$uuid     /mnt/${dirName}   xfs     noatime,nodiratime 0       0">>/etc/fstab
  done

  if [ "$batchSuccess" == true ]; then
    mount -a
    echo "Batch mount success!"
    #保存硬盘序列号
    saveSerial
  else
    echo "Batch mount fail!"
  fi

}

saveSerial(){
  # 定义时间变量名和显示时间格式
  fileNameDate=$(date +%Y%m%d-%H%M%S)
  fileName=/mnt/"disk-info-${fileNameDate}".txt
  echo "硬盘 挂载目录  硬盘序列号 UUID" >>"${fileName}"

  for disk in $(parted -l |grep 'Disk /dev/sd' |grep Disk |grep TB |awk '{split($2,s,":"); print s[1]}')
  do
    serial=$(lsblk --nodeps -no serial "$disk")
    dirName=${disk:5}
    uuid=$(lsblk -lf "$disk" |awk '{print $3}' |grep '-')
    echo "$disk /mnt/${dirName}  $serial $uuid" >>"${fileName}"
  done
  echo "Save Serial success!"
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
 "batchMount")
 batchMount
 ;;
 "saveSerial")
 saveSerial
 ;;
 "batchRm")
 batchRm
 ;;
 *)
 usage
 ;;
esac
