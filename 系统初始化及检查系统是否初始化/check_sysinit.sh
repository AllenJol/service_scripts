#!/bin/bash

if [ $UID -ne 0 ];then
  echo "you must be root"
  exit 1
fi

export PATH=$PATH:/bin:/sbin:/usr/bin

. /etc/init.d/functions

if [ `grep "en_US.UTF-8" /etc/sysconfig/i18n | wc -l` -eq 1 ];then
  action "/etc/sysconfig/i18n" /bin/true
  sleep 1
else
  action "/etc/sysconfig/i18n" /bin/false
  sleep 1
fi

if [ `chkconfig --list | egrep "3:on|3:启用" | egrep "crond|network|sshd" | wc -l` -eq 3 ];then
  action "sys service init" /bin/true
  sleep 1
else
  action "sys service init" /bin/false
  sleep 1
fi

if [ `grep "65535" /etc/security/limits.conf | wc -l` -eq 1 ];then
  action "/etc/security/limits.conf" /bin/true
  sleep 1
else
  action "/etc/security/limits.conf" /bin/false
  sleep 1
fi
