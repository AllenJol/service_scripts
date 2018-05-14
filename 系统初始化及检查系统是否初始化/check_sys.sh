#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#__Description__: 检查系统是否已经初始化精简过

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
if [ `grep "zh_CN.UTF-8" /etc/sysconfig/i18n | wc -l` -eq 1 ];then
  action "/etc/sysconfig/i18n" /bin/true
  sleep 1
else
  action "/etc/sysconfig/i18n" /bin/false
  sleep 1
fi

#检查开机自启
if [ `chkconfig --list | egrep "3:on|3:启用" | egrep "crond|network|sshd" | wc -l` -eq 3 ];then
  action "sys service init" /bin/true
  sleep 1
else
  action "sys service init" /bin/false
  sleep 1
fi

#检查文件打开数
if [ `grep "65535" /etc/security/limits.conf | wc -l` -eq 1 ];then
  action "/etc/security/limits.conf" /bin/true
  sleep 1
else
  action "/etc/security/limits.conf" /bin/false
  sleep 1
fi

#检查阿里云对时
if [ `grep "ntp1.aliyun.com" /etc/crontab | wc -l` -ne 0 ];then
  action "ntpdate is successfully." /bin/true
else
  action "ntpdate is successfully." /bin/false
fi

#检查selinux是否已经关闭
if [ ${selinux_status} = "disabled" ];then
  action "disabled selinux successfully." /bin/true
else
  action "disabled selinux successfully." /bin/false
fi

