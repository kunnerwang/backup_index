#!/bin/bash
# 备份脚本会通过tae的进程，查找索引路径；
# 所以备份脚本的计划任务请设置在升级时间段外；
# 避免由于升级操作，导致脚本找不到索引路径；
# @author Lance

# 备份路径
backupPath='/backup/IndexBackup'
dateTime=`date "-d 2 day ago" +%Y%m%d`

set -e
basePath=${PWD}
# 判断当前服务器是否是主机
taePID=`ps -ef | grep 'java' | grep -v 'grep' | grep 'tae' | awk '{print $2}'`
if [[ $taePID =~ ^[0-9]+$ ]]; then
    taePath=`pwdx ${taePID} | awk '{print $2}'`
    indexPath="${taePath}/data/tae/index-store"
    echo `date +"%Y-%m-%d %H:%M:%S"`" INFO 获取到索引路径 ${indexPath}" >> ${basePath}/index_backup.log
else
    echo `date +"%Y-%m-%d %H:%M:%S"`" ERROR 未获取到索引路径，${dateTime} 打包失败" >> ${basePath}/index_backup.log
    exit 1
fi

# 判断备份路径是否存在，创建备份路径
if [ ! -d ${backupPath} ]; then
    echo "${backupPath}不存在"
    echo `date +"%Y-%m-%d %H:%M:%S"`" WARN ${backupPath} 不存在，已创建 ${backupPath}" >> ${basePath}/index_backup.log
    mkdir -pv ${backupPath}
fi

# 打包索引
if [ -d "${indexPath}/task${dateTime}" -a -d "${indexPath}/speech${dateTime}" ]; then
    cd ${indexPath}
    tar -czf ${backupPath}/index_backup_${dateTime}.tar.gz meta.d task${dateTime} speech${dateTime}
    echo $?
    if [ $? -eq 0 ]; then
        echo `date +"%Y-%m-%d %H:%M:%S"`" INFO ${dateTime} 的索引打包成功" >> ${basePath}/index_backup.log
    else
        echo `date +"%Y-%m-%d %H:%M:%S"`" ERROR ${dateTime} 的索引打包成失败" >> ${basePath}/index_backup.log
    fi
else
    echo `date +"%Y-%m-%d %H:%M:%S"`" WARN ${dateTime} 没有生成索引" >> ${basePath}/index_backup.log
fi
