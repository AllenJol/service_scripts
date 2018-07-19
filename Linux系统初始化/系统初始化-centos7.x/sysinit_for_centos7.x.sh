#!/bin/bash
# ******************************************************
#__Author__         : Allen_Jol
#__Last modified__  : 2018-07-17 22:02
#__Filename__       : sysinit_for_centos7.sh
# __Description__: 为centos7.x系列系统进行初始优化
# ******************************************************

#判断不是root用户不让直行此脚本
if [ $UID -ne 0 ];then
  echo -e "\033[1;33myou must be root\033[0m"
  exit 1
fi

#判断是否加了第一个位置参数，即主机名
if [ ! -n "$1" ];then
  echo -e "\033[1;31mUsage: $0 hostname\033[0m" && exit 1
else
  echo -e "\033[1;33mSys will init after 1 minute.\033[0m" && sleep 1
fi
#检测网络是否正常
ping -c 1 www.baidu.com >>/dev/null
[ ! $? -eq 0 ] && echo "Networking not configure,please check." && exit 1

hostnamectl set-hostname $1
echo "hostnamectl set-hostname $1" >>/etc/rc.d/rc.local
#加载系统函数库
. /etc/init.d/functions

platform=`uname -i`
if [ $platform != "x86_64" ];then 
  echo -e "\e[1;31mthis script is only for 64bit Operating System !\e[0m"
  exit 1
else
  echo -e "\e[1;31mthe platform is ok,it will be init_system...\e[0m"
fi
cat << EOF
+---------------------------------------+
|   your system is CentOS 7 x86_64      |
|      start optimizing.......          |
+---------------------------------------
EOF

#添加公网DNS地址
#cat >> /etc/resolv.conf << EOF
#nameserver 114.114.114.114
#EOF

#Yum源更换为国内阿里源
yum -y install wget telnet >>/dev/null
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >>/dev/null
#添加阿里的epel源
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo >>/dev/null
# rpm -ivh http://dl.Fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
action "Config repos.d--->ok" /bin/true
sleep 1
echo -e "\e[1;31m重建缓存中，请稍等...\e[0m"
#yum重新建立缓存
yum clean all >>/dev/null
yum makecache >>/dev/null
#同步时间
yum -y install ntp >>/dev/null
/usr/sbin/ntpdate ntp1.aliyun.com
echo '00 00 * * * root /usr/sbin/ntpdate ntp1.aliyun.com && hwclock -w > /dev/null 2>&1' >>/etc/crontab
systemctl  restart crond.service
timedatectl set-timezone Asia/Shanghai
#cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
action "Config ntp--->ok" /bin/true
sleep 1
echo ""

#安装常用软件
echo -e "\e[1;31m安装常用软件包，请稍等...\e[0m"
yum -y install vim lrzsz net-snmp nmap unzip net-tools tree \
    ncurses ncurses-devel gcc gcc-c++ openssl openssl-devel >>/dev/null
yum -y install zlib zlib-devel openssh-clients man mtr traceroute bash-completion >>/dev/null
action "Config yum--->ok" /bin/true
sleep 1
echo ""

#设置最大打开文件描述符数
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       655350
*           hard   nofile      655350
EOF

#禁用selinux和防火墙
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
systemctl disable firewalld.service 
systemctl stop firewalld.service
yum -y install iptables
systemctl stop iptales
action "Disabled selinux and firewalld--->ok" /bin/true
sleep 1
echo ""

#config ssh
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
systemctl restart sshd.service
action "Config ssh speed--->ok" /bin/true
sleep 1
echo ""

#内核参数优化
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_local_port_range = 32768 61000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_abort_on_overflow = 0
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
EOF
/sbin/sysctl -p
action "Config sys kernel--->ok" /bin/true
sleep 1
echo ""

cat << EOF
+-------------------------------------------------+
|               optimizer is done                 |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF
action "System init--->ok" /bin/true
