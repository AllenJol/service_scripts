#!/bin/bash
#__Author__:Allen_Jol at 2018-03-27 03:46:59
#Description: redis-4.0.8 单实例 安装脚本 2.x版本的redis不支持集群模式
#redis安装后，不需要安装tcl8.5也是可以使用的，但是要使用Redis的测试用例也就是tests目录下面用的是tcl脚本,就需要安装tcl8.5 或更高版本

DATE=`date +%Y%m%d`
DIR="/usr/local/src"
CPU_CORE=`grep processor /proc/cpuinfo | wc -l`
TCL_VERSION="tcl8.6.6"
TCL_DOWN_URL=" https://nchc.dl.sourceforge.net/project/tcl/Tcl/8.6.6/${TCL_VERSION}-src.tar.gz"
REDIS_VERSION="redis-4.0.8"
REDIS_DOWN_URL="http://download.redis.io/releases/${REDIS_VERSION}.tar.gz"

function check_root(){
  if [ $UID -ne 0 ];then
    echo -e "\e[1;35mMust be root to excute this script.\e[0m"
    exit 1
  fi
}
check_root

function install_required_packages(){
  NETTEST=`ping -c 1 www.baidu.com >>/dev/null`
  if [ $? -eq 0 ];then
    echo -e "Install required packages,please wait...\t Or you can press \e[5;35m[ctrl+c]\e[0m to exit."
    yum -y install make gcc gcc-c++ wget lrzsz zlib zlib-devel openssl openssl-devel curl curl-devel ncurses ncurses-devel >>/dev/null
  else
    echo -e "\e[1;35mnetwork is error,please check first.\e[0m"
    exit 1
  fi
}

function tcl_install(){
  if [ -f ${DIR}/${TCL_VERSION}-src.tar.gz ];then
    echo "There have ${TCL_VERSION}-src.tar.gz,please check it first."
    exit 1
  else
    echo "Doenload ${TCL_VERSION}-src.tar.gz now and install it,please wait for a moment..." && sleep 1
    cd ${DIR} && wget -c ${TCL_DOWN_URL} && tar -zxf ${TCL_VERSION}-src.tar.gz
    cd ${DIR}/tcl8.6.6/unix && ./configure --prefix=/usr/local/tcl8.6.6 --enable-64bit >>/dev/null
    make -j ${CPU_CORE} >>/dev/null && make install >>/dev/null
    echo "export PATH=/usr/local//tcl8.6.6/bin:$PATH" >>/etc/profil
    source /etc/profile
  fi
}

function redis_install(){
  if [ -f "${DIR}/${REDIS_VERSION}.tar.gz" ];then
    echo "There have ${REDIS_VERSION}.tar.gz,please remove it or check it first."
    exit 1
  else
    echo "Download and configure ${REDIS_VERSION}.tar.gz now,please wait..."
    cd ${DIR} && wget -c ${REDIS_DOWN_URL} && tar -zxf ${REDIS_VERSION}.tar.gz >>/dev/null
    cd ${REDIS_VERSION}
    make PREFIX=/usr/local/redis install
    if [ $? -ne 0 ];then
      make MALLOC=libc && make install
    else
      echo "configure ${REDIS_VERSION} successfully."
    fi
    echo "configure redis.conf now..."
    mkdir -p /usr/local/redis/{etc,logs}
    #拷贝配置文件
    \cp -a ${DIR}/${REDIS_VERSION}/redis.conf /usr/local/redis/etc/redis.conf
    \cp -a ${DIR}/${REDIS_VERSION}/sentinel.conf /usr/local/redis/etc/sentinel.conf
    #备份配置文件
    cp /usr/local/redis/etc/redis.conf /usr/local/redis/etc/redis.conf.$DATE
    cp /usr/local/redis/etc/sentinel.conf /usr/local/redis/etc/sentinel.conf.$DATE
    cp -a /usr/local/redis/bin/* /usr/bin/
    echo "vm.overcommit_memory = 1">>/etc/sysctl.conf && sysctl -p
    echo 'echo 511 > /proc/sys/net/core/somaxconn' >>/etc/rc.local
    echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >>/etc/rc.local
    echo 511 > /proc/sys/net/core/somaxconn
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    sed -i 's#daemonize no#daemonize yes#g' /usr/local/redis/etc/redis.conf
    #开放所有比较危险，具体可根据实际环境需求操作
    sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" /usr/local/redis/etc/redis.conf
    sed -i "s/timeout 0/timeout 30/g" /usr/local/redis/etc/redis.conf
    sed -i "s#pidfile \/var\/run\/redis\_6379\.pid#pidfile \/usr\/local\/redis\/logs\/redis\.pid#g" /usr/local/redis/etc/redis.conf
    sed -i "s#logfile \"\"#logfile \/usr\/local\/redis\/logs\/redis\.log#g" /usr/local/redis/etc/redis.conf
    cd /usr/local/redis
    nohup  /usr/local/redis/bin/redis-server  /usr/local/redis/etc/redis.conf > /dev/null 2>&1 &
    [ $? -eq 0 ] && echo "redis start successfully." || echo "redis start faild.please check..." 
    echo "nohup  /usr/local/redis/bin/redis-server  /usr/local/redis/etc/redis.conf > /dev/null 2>&1 &" >>/etc/rc.local
  fi
}

function main(){
  check_root
  install_required_packages
  tcl_install
  redis_install
}
main

