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
if [ ! -d "/usr/local/java" ];then
  mkdir -p /usr/local/java
else
  echo "dir have exsits."
fi
}

function check_jdk(){
 JAVA=`java -version | wc -l`
  if [ ${JAVA} -eq 0 ] ;then
    echo "There is no java jdk installed."
  else
    echo "There have installed java jdk,please check..."
    exit 1
  fi
}

function jdk8_down_install(){
  NETSTAT="ping -c 1 www.baidu.com >>/dev/null"
  if [ $? -ne 0 ];then
    echo "network is error,please check..."
  else
    echo "network is ok,download ${JDK8_VERSION} now.please wait for a moment."
    cd /usr/local/java 
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz" 
    tar -zxf ${JDK8_VERSION} -C /usr/local/java && ln -s /usr/local/java/jdk1.8.0_41 /usr/jdk
    #rpm -ivh ${JDK8_VERSION} && ln -s /usr/local/java/${JDK8_VERSION}  /usr/jdk
  fi
echo "export JAVA_HOME=/usr/local/java/jdk1.8.0_141" >>/etc/profile
echo "export PATH=$JAVA_HOME/bin:$PATH" >>/etc/profile
echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >>/etc/profile
source /etc/profile
}

function main(){
  check_root
  check_dir
  check_jdk
  jdk8_down_install
}
main
