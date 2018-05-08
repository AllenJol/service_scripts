#!/bin/bash
#__Author__:Allen_Jol at 2018-03-27 19:13:17
#Description: jdk8 install

JDK8_VERSION="jdk-8u141-linux-x64.tar.gz"

function check_root(){
  if [ $UID -ne 0 ];then
    echo "you must be root to excute this scripts."
    exit 1
  fi
}

function check_dir(){
if [ ! -d "/usr/java" ];then
  mkdir -p /usr/java
else
  echo -e "\033[1;31java dir have exsits,and scripts has locked.\033[0m"
  exit 1
fi
}

function check_jdk(){
 JAVA=`java -version | wc -l`
  if [ ${JAVA} -eq 0 ] ;then
    echo -e "\033[1;31mIgnore Error about [ java command not found ]\033[0m"
	echo -e "\033[1;33mThere is no java jdk installed.\033[0m"
  else
    echo -e "\033[1;33mThere have installed java jdk,please check...\033[0m"
    exit 1
  fi
}

function jdk8_down_install(){
  NETSTAT="ping -c 1 www.baidu.com >>/dev/null"
  if [ $? -ne 0 ];then
    echo "network is error,please check..."
  else
    echo "network is ok,download ${JDK8_VERSION} now.please wait for a moment."
    cd /usr/java 
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz" 
    tar -zxf ${JDK8_VERSION} -C /usr/java && ln -s /usr/java/jdk1.8.0_141 /usr/jdk
    #rpm -ivh ${JDK8_VERSION} && ln -s /usr/local/java/${JDK8_VERSION}  /usr/jdk
  fi
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_141' >>/etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >>/etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >>/etc/profile
source /etc/profile
}

function main(){
  check_root
  check_dir
  check_jdk
  jdk8_down_install
}
main
