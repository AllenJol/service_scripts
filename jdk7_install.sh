#!/bin/bash
#__Author__:Allen_Jol at 2018-03-27 15:40:04
#Description: jkd 7 install

JDK7_VERSION="jdk1.7.0_79"
JDK7_DOWN_URL="http://ozi3kq0eb.bkt.clouddn.com/${JDK7_VERSION}.tar.gz"

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
  echo "dir have exsits and locked,please check..."
  exit 1
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

function jdk7_down_install(){
    NETSTAT="ping -c 1 www.baidu.com >>/dev/null"
  if [ $? -ne 0 ];then
    echo "network is error,please check..."
  else
    echo "network is ok,download ${JDK8_VERSION} now.please wait for a moment."
    cd /usr/local/java 
    wget -c ${JDK7_DOWN_URL}
    tar -zxf ${JDK7_VERSION}.tar.gz -C /usr/local/java && ln -s /usr/local/java/jdk1.7.0_79 /usr/jdk
    #rpm -ivh ${JDK8_VERSION} && ln -s /usr/local/java/${JDK8_VERSION}  /usr/jdk
  fi
echo 'export JAVA_HOME=/usr/local/java/jdk1.7.0_79' >>/etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >>/etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >>/etc/profile
source /etc/profile
}

function main(){
  check_root
  check_dir
  check_jdk
  jdk7_down_install
}
main
