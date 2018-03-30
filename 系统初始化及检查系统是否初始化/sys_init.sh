#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#Description: 精简系统开机自启

SERVICE=`which service`
CHKCONFIG=`which chkconfig`
DATETEM=`date +"%Y-%m-%d_%H-%M-%S"`

[ ! -n "$1" ] && echo "Usage: $0 hostname" && exit 1 || echo "Sys will init after 1 minute." && sleep 1

if [ $UID -ne 0 ];then
  echo "you must be root"
  exit 1
fi

#加载系统函数库
. /etc/init.d/functions

echo "hostname $1" >>/etc/rc.d/rc.local

#安装所需的基础包，包组
function Install_Require_Packages(){
  echo "Install require packages,please wait for a moment."
  yum -y install sysstat htop ntp net-snmp nmap lrzsz wget unzip \
  epel-release net-tools ncurses ncurses-devel >>/dev/null
  yum -y install gcc gcc-c++ openssl openssl-devel zlib zlib-devel \
  openssh-clients man tree bash-completion >>/dev/null
  yum -y groupinstall "Development tools" >>/dev/null
  action "Config yum--->ok" /bin/true
  sleep 1
}

#配置yum源
#function Config_Yum(){
#  echo "Config Yum CentOS-Base.repo."
#  cd /etc/yum.repos.d/
#  \cp CentOS-Base.repo CentOS-Base.repo.$DATETEM
#  ping -c 1 www.baidu.com >>/dev/null
#  [ ! $? -eq 0 ] && echo "Networking not configure,please check." && exit 1
#  wget --quiet -o /dev/null http://mirrors.sohu.com/help/CentOS-Base-sohu.repo
#  \cp CentOS-Base-sohu.repo CentOS-Base.repo
#  action "Config repo--->ok" /bin/true
#  sleep 1
#}

#更改成中文字符集编码也没必要
#fnction Init_I18n(){
#  \cp /etc/sysconfig/i18n /etc/sysconfig/i18n.$DATE
#  sed -i 's#LANG="en_US.UTF-8"#LANG="zh_CN.UTF-8"#g' /etc/sysconfig/i18n
#  source /etc/sysconfig/i18n
#  echo 'LANG="zh_CN.UTF-8"' >> /etc/sysconfig/i18n
#}

#关闭防火墙和selinux
function Init_Iptables_selinux(){
  echo "Close Selinux and Iptables"
  \cp /etc/selinux/config /etc/selinux/config.$DATETEM
  /etc/init.d/iptables stop
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  /etc/init.d/iptables stop
  chkconfig iptables off
  action "Close SELINUX--->ok and Disables iptables---ok" /bin/true
  sleep 1
}

function Init_Services(){
  echo "Close Nouserful services"
  for LEV in `chkconfig --list|egrep "3:on|3:启用"|awk '{print $1}'`;do chkconfig --level 3 $LEV off;done
  for LEV in crond syslog snmpd sshd network;do chkconfig --level 3 $LEV on;done
  action "关闭不需要的服务--->ok" /bin/true
  sed -i "s/id:5:initdefault/id:3:initdefault/" `grep "id:5:initdefault" -rl /etc/inittab`  #只加载字符终端
  sleep 1
}

#修改ssh端口：注意，一定要在关闭了selinux后才可以修改，否则服务器会连不上
#我们可以改好一个配置文件，然后和脚本放在一个目录下，备份原始文件后，再cp文件过去即可
#function Init_ssh(){
#  echo "----------sshconfig 修改ssh默认登录端口，禁止root登陆----------"
#  \cp /etc/sshd/sshd_config /etc/ssh/sshd_config.$DATETEM
#  sed -i 's%#Port 22%Port 202%' /etc/sshd/sshd_config
#  sed -i 's%#PermitRootLogin yes%PermitRootLogin no%' /etc/sshd/sshd_config
#  sed -i 's%#PermitEmptyPasswords no%PermitEmptyPasswords no%' /etc/sshd/sshd_config
#  sed -i 's%#UseDNS yes%UseDNS no%' /etc/sshd/sshd_config
#  /etc/init.d/sshd reload && action "修改ssh默认端口，禁止root登陆--->ok" /bin/true || \
#  action "修改ssh默认端口，禁止root登陆--->false" /bin/false
#}

#function Add_User(){
#  echo "----------添加系统用户----------"
#  \cp /etc/sudoers /etc/sudoers.$DATETEM
#  saUserArr=(liyu yunwei2 yunwei3)
#  groupadd -g 888 sa
#  for ((i=0;i<${#saUserArr[@]};i++))
#  do
#    useradd -g sa -u 88$i ${saUserArr[$i]}
#    echo "${saUserArr[$i]}123" | passwd ${saUserArr[$i]} --stdin 
#    #设置sudo权限
#    #[ $(grep "${saUserArr[$i]} ALL=(ALL) NOPASSWD: ALL") /etc/sudoers | wc -l) -le 0 ] && echo "${saUserArr[$i]} ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
#    [ `grep "\%a" | grep -v grep | wc -l` -ne 1 ] && \
#    echo "%sa    ALL=(ALL)    NOPASSWD:ALL" >>/etc/sudoers
#  done
#    /usr/sbin/visudo -c
#    [ $? -ne 0 ] && /bin/cp /etc/sudoers.$DATETEM /etc/sudoers && echo "Sudoers not configure--->failed" && exit 1
#    action "用户添加成功--->ok" /bin/true
#}

function Ntp_Sys_Date(){
  if [ `grep pool.ntp.org /var/spool/cron/root | grep -v grep | wc -l` -lt 1 ];then
    echo "*/5 * * * * /usr/sbin/ntpdate cn.pool.ntp.org >>/dev/null 2>&1 &" >>/var/spool/cron/root
  fi
  echo "00 00 * * * /usr/sbin/ntpdate cn.pool.ntp.org >>/dev/null" >>/etc/crontab
  echo "/usr/sbin/ntpdate cn.pool.ntp.org >>/dev/null" >>/etc/rc.d/rc.local
}

function Open_Files(){
  echo "----------调整最大系统文件打开数为65535个----------"
  \cp /etc/security/limits.conf /etc/security/limits.conf.$DATETEM
  #sed -i '/# End of file/i\*\t\t-\tnofile\t\t65535' /etc/security/limits.conf 在End of file上面插入
  echo '*  -  nofile  65535' >> /etc/security/limits.conf
  ulimit -HSn 65535
  action "调整最大文件系统打开数--->ok (修改后重新登录生效)"
  sleep 1
}

function Optimization_Kernel(){
  echo "----------优化系统内核----------"
  \cp /etc/sysctl.conf /etc/sysctl.conf.$DATETEM
  cat>>/etc/sysctl.conf<<EOF
  net.ipv4.tcp_timestamps = 0
  net.ipv4.tcp_synack_retries = 2
  net.ipv4.tcp_syn_retries = 2 
  net.ipv4.tcp_mem = 94500000 915000000 927000000
  net.ipv4.tcp_max_orphans = 3276800
  net.core.wmem_default = 8388608
  net.core.rmem_default = 8388608
  net.ipv4.tcp_rmem = 4096 87380 16777216
  net.ipv4.tcp_wmem = 4096 87380 16777216
  net.core.netdev_max_backlog = 32768
  net.core.somaxconn = 32768
  net.ipv4.tcp_syncookies = 1
  net.ipv4.tcp_tw_reuse = 1
  net.ipv4.tcp_tw_recycle = 1
  net.ipv4.tcp_fin_timeout = 1
  net.ipv4.tcp_keepalive_time = 600
  net.ipv4.tcp_max_syn_backlog = 65536
  net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p && action "内核优化" /bin/true || action "内核优化" /bin/false
}

#function Init_Safe(){
#  echo "----------禁止用ctrl+alt+del三个键重启系统----------"
#  \cp /etc/inittab /etc/inittab.$DATETEM
#  sed -i "s/ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/#ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/" /etc/inittab
#  /sbin/init q
#  [ $? -ne 0 ] && action "禁止ctrl+alt+del三个键重启系统" /bin/true || action "禁止ctrl+alt+del三个键重启系统" /bin/false
#}

function Start_Sys_Init(){
echo 'echo 25165824 > /proc/sys/net/core/wmem_max'  >>/etc/rc.d/rc.local
echo 'echo 25165824 > /proc/sys/net/core/rmem_max'  >>/etc/rc.d/rc.local
echo 'echo 8388608 > /proc/sys/net/core/wmem_default'  >>/etc/rc.d/rc.local
echo 'echo 8388608 > /proc/sys/net/core/rmem_default'  >>/etc/rc.d/rc.local
}

function main(){
  Install_Require_Packages
  #Config_Yum
  #Init_I18n
  Init_Iptables_selinux
  Init_Services
  #Init_ssh
  #Add_User
  #Ntp_Sys_Date
  Open_Files
  Optimization_Kernel
  #Init_Safe
  Start_Sys_Init
}
main
