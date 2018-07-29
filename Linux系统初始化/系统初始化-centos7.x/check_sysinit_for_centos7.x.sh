#!/bin/bash
# ******************************************************
#__Author__         : Allen_Jol
#__Last modified__  : 2018-07-17 22:45
#__Filename__       : check_sysinit_7.x.sh
# __Description__: 检查centos7.x系统是否已经初始化过 
# ******************************************************

selinux_status=`cat /etc/selinux/config | grep -v "^#" | grep "SELINUX=" | cut -d"=" -f2`

#check_root
if [ $UID -ne 0 ];then
  echo -e "\033[1;33myou must be root\033[0m"
  exit 1
fi

export PATH=$PATH:/bin:/sbin:/usr/bin

#加载系统函数库
. /etc/init.d/functions

#检查字符集编码
#if [ `grep "zh_CN.UTF-8" /etc/sysconfig/i18n | wc -l` -eq 1 ];then
  #action "/etc/sysconfig/i18n" /bin/true
  #echo ""
  #sleep 1
#else
  #action "/etc/sysconfig/i18n" /bin/false
  #echo ""
  #sleep 1
#fi

#检查文件打开数
if [ `grep "655350" /etc/security/limits.conf | wc -l` -eq 2 ];then
  action "/etc/security/limits.conf" /bin/true
  echo ""
  sleep 1
else
  action "/etc/security/limits.conf" /bin/false
  echo ""
  sleep 1
fi

#检查阿里云对时
if [ `grep "ntp1.aliyun.com" /etc/crontab | wc -l` -ne 0 ];then
  action "ntpdate is successfully..." /bin/true
  echo ""
else
  action "ntpdate is successfully..." /bin/false
  echo ""
fi

#检查selinux是否已经关闭
if [ ${selinux_status} = "disabled" ];then
  action "disabled selinux successfully..." /bin/true
  echo ""
else
  action "disabled selinux successfully..." /bin/false
  echo ""
fi
