#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#Description: tomcat 7 install

. ./jdk7_install.sh

check_root
check_dir
check_jdk
jdk7_down_install
  
source /etc/profile

DIR="/usr/local/src"
TOMCAT7_PATH="/usr/local/tomcat7"
TOMCAT7_VERSION="apache-tomcat-7.0.73"
TOMCAT7_DOWN_URL="http://ozi3kq0eb.bkt.clouddn.com/${TOMCAT7_VERSION}.tar.gz"

#apache7_version=7.0.73
#jdk1_7_version=1.7.0_79
#apache7_url=http://ozi3kq0eb.bkt.clouddn.com/apache-tomcat-$apache7_version.tar.gz
#jdk1_7_url=http://ozi3kq0eb.bkt.clouddn.com/jdk$jdk1_7_version.tar.gz

function check_dir(){
  if [ -d "${TOMCAT7_PATH}" ];then
    echo "tomcat dir have exsits,please check..."
    exit 1
  else
    sleep 1
  fi
}

function tomcat7_down_install(){
 cd ${DIR} && wget -c ${TOMCAT7_DOWN_URL}
 tar -zxf ${TOMCAT7_VERSION}.tar.gz
 mv ${TOMCAT7_VERSION}/ ${TOMCAT7_PATH}
 #mv ${TOMCAT7_PATH}/conf/server.xml ${TOMCAT7_PATH}/conf/server.xml.default
 #cp ${DIR}/server.xml ${TOMCAT7_PATH}/conf/server.xml
 ${TOMCAT7_PATH}/bin/catalina.sh start
}

function main(){
  check_dir
  tomcat7_down_install
}
main
