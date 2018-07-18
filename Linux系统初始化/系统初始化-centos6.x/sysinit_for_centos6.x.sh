#!/bin/bash
#__Author__:Allen_Jol at 2016-03-21 13:52:13
#__Description__: 精简系统开机自启

SERVICE=`which service`
CHKCONFIG=`which chkconfig`
DATETEM=`date +"%Y-%m-%d_%H-%M-%S"`

[ ! -n "$1" ] && echo -e "\033[1;31mUsage: $0 hostname\033[0m" && exit 1 || echo -e "\033[1;33mSys will init after 1 minute.\033[0m" && sleep 1

if [ $UID -ne 0 ];then
  echo -e "\033[1;33myou must be root\033[0m"
  exit 1
fi

#加载系统函数库
. /etc/init.d/functions

echo "hostname $1" >>/etc/rc.d/rc.local

#配置yum源
function Config_Yum(){
  echo -e "\033[1;33m---------- Config Yum CentOS-Base.repo,please wait for moments ----------\033[0m"
  cd /etc/yum.repos.d/
  yum -y install wget >>/dev/null
  \mv CentOS-Base.repo CentOS-Base.repo.$DATETEM
  ping -c 1 www.baidu.com >>/dev/null
  [ ! $? -eq 0 ] && echo "Networking not configure,please check." && exit 1
  wget --quiet -o /dev/null /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
  #wget --quiet -o /dev/null /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
  \mv Centos-6.repo CentOS-Base.repo
  #\mv Centos-7.repo CentOS-Base.repo
  yum clean all >>/dev/null && yum makecache >>/dev/null
  wget --quiet -o /dev/null /etc/yum.repos.d/epel-6.repo http://mirrors.aliyun.com/repo/epel-6.repo
  #wget --quiet -o /dev/null /etc/yum.repos.d/epel-7.repo https://mirrors.aliyun.com/repo/epel-7.repo
  #yum -y install epel-release也是安装的阿里云的epel源
  yum clean all >>/dev/null && yum makecache >>/dev/null
  action "Config repo--->ok" /bin/true
  sleep 2
  echo ""
}

#安装所需的基础包，包组
function Install_Require_Packages(){
  echo "Install require packages,please wait for a moment."
  yum -y install epel-release sysstat htop ntp net-snmp nmap lrzsz wget unzip \
  net-tools ncurses ncurses-devel gcc gcc-c++ openssl openssl-devel >>/dev/null
  yum -y install zlib zlib-devel openssh-clients man mtr traceroute tree bash-completion >>/dev/null
  yum -y groupinstall "Development tools" >>/dev/null
  action "Config yum--->ok" /bin/true
  sleep 2
  echo ""
}

#更改成中文字符集编码，非必要
#function Init_I18n(){
  #\cp /etc/sysconfig/i18n /etc/sysconfig/i18n.$DATE
  #sed -i 's#LANG="en_US.UTF-8"#LANG="zh_CN.UTF-8"#g' /etc/sysconfig/i18n
  #echo 'LANG="zh_CN.UTF-8"' >> /etc/sysconfig/i18n
  #sed -i '/LANG\=/s/^/#/' /etc/sysconfig/i18n
  #sed -i '1a LANG="zh_CN.UTF-8"' /etc/sysconfig/i18n
  #source /etc/sysconfig/i18n
  #action "Config encoding--->ok" /bin/true
  #echo ""
#}

#关闭防火墙和selinux
function Init_Iptables_selinux(){
  echo "Close Selinux and Iptables"
  \cp /etc/selinux/config /etc/selinux/config.$DATETEM
  iptables -F && /etc/init.d/iptables save
  /etc/init.d/iptables stop
  chkconfig iptables off
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  action "Close SELINUX--->ok and Disables iptables---ok" /bin/true
  sleep 2
  echo ""
}

function Init_Services(){
  echo "----------Close Nouserful services----------"
  for sun in `chkconfig --list|egrep "3:on|3:启用"|awk '{print $1}'`;do chkconfig --level 3 $sun off;done
  for sun in crond syslog snmpd sshd network;do chkconfig --level 3 $sun on;done
  #chkconfig --list | egrep "3:on|3:关闭"
  action "关闭不需要的服务--->ok" /bin/true
  sed -i "s/id:5:initdefault/id:3:initdefault/" `grep "id:5:initdefault" -rl /etc/inittab`  #只加载字符终端
  sleep 2
  echo ""
}

#修改ssh端口：注意，一定要在关闭了selinux后才可以修改，否则服务器会连不上
#我们可以改好一个配置文件，然后和脚本放在一个目录下，备份原始文件后，再cp文件过去即可
function config_ssh(){
#  echo "----------sshconfig 修改ssh默认登录端口，禁止root登陆----------"
#  \cp /etc/sshd/sshd_config /etc/ssh/sshd_config.$DATETEM
#  sed -i 's%#Port 22%Port 202%' /etc/sshd/sshd_config
#  sed -i 's%#PermitRootLogin yes%PermitRootLogin no%' /etc/sshd/sshd_config
#  sed -i 's%#PermitEmptyPasswords no%PermitEmptyPasswords no%' /etc/sshd/sshd_config
#  sed -i 's%#UseDNS yes%UseDNS no%' /etc/sshd/sshd_config
#  /etc/init.d/sshd reload && action "修改ssh默认端口，禁止root登陆--->ok" /bin/true || \
#  action "修改ssh默认端口，禁止root登陆--->false" /bin/false
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
/etc/init.d/sshd reload && action "修改ssh默认端口，禁止root登陆--->ok" /bin/true || \
action "修改ssh默认端口，禁止root登陆--->false" /bin/false
}

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
  echo "----------和阿里云时间服务器对时----------"
  sed -i "s/America\/New_York/Asia\/Shanghai/" /etc/sysconfig/clock
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  if [ `grep "ntp1.aliyun.com" /etc/crontab | grep -v grep | wc -l` -lt 1 ];then
    echo "*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com >>/dev/null 2>&1 &" >>/etc/crontab
    echo "/usr/sbin/ntpdate ntp1.aliyun.com >>/dev/null" >>/etc/rc.d/rc.local
    action "和阿里云时间服务器同步--->ok" /bin/true
  else
    action "和阿里云时间服务器同步--->flase" /bin/false
  fi
  echo ""
}

function Open_Files(){
  echo "----------调整最大系统文件打开数为65535个----------"
  \cp /etc/security/limits.conf /etc/security/limits.conf.$DATETEM
  #sed -i '/# End of file/i\*\t\t-\tnofile\t\t65535' /etc/security/limits.conf 在End of file上面插入
  echo '*  -  nofile  65535' >> /etc/security/limits.conf
  ulimit -HSn 65535
cat >>/etc/rc.local<<EOF
#open files
ulimit -HSn 65535
#stack size
ulimit -s 65535
EOF
  action "调整最大文件系统打开数--->ok (修改后重新登录生效)"
  sleep 2
  echo ""
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
  #tw_recycle = 1 表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭
  net.ipv4.tcp_tw_recycle = 1
  net.ipv4.tcp_fin_timeout = 1
  net.ipv4.tcp_keepalive_time = 600
  net.ipv4.tcp_max_syn_backlog = 65536
  net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p && action "内核优化" /bin/true || action "内核优化" /bin/false
echo ""
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

#定时自动清理/var/spool/clientmqueue/目录垃圾文件，放置inode节点被占满
#本优化点，在6.4上可以忽略不需要操作即可！
function clean_spool(){
  [ -d "/server/scripts" ] || mkdir -p /server/scripts
  cd /server/scripts && touch spool_clean.sh
  echo 'find /var/spool/clientmqueue/ -type f -mtime +30 | xargs rm-f' >>/server/scripts/spool_clean.sh
  chmod +x /server/scripts/spool_clean.sh
  echo '*/30 * * * * /bin/sh /server/scripts/spool_clean.sh >/dev/null 2>&1'>>/etc/crontab
  echo ""
}

#function change_dns(){
#sed -i '/nameserver/s/^/#/' /etc/resolv.conf
#cat>>/etc/resolv.conf<<EOF
#nameserver 114.114.114.114
#nameserver 8.8.8.8
#EOF
#/etc/init.d/network restart
#}

function main(){
  Config_Yum
  Install_Require_Packages
  #Init_I18n
  Init_Iptables_selinux
  Init_Services
  config_ssh
  #Add_User
  Ntp_Sys_Date
  Open_Files
  Optimization_Kernel
  #Init_Safe
  Start_Sys_Init
  clean_spool
  #change_dns
}
main
