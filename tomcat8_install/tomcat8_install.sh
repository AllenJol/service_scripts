#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#Description: tomcat 7 install

. ./jdk8_install.sh
. /etc/profile

DIR="/usr/local/src"
TOMCAT8_PATH="/usr/local/tomcat8"
TOMCAT8_VERSION="apache-tomcat-8.5.29"
TOMCAT8_DOWN_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.29/bin/${TOMCAT8_VERSION}.tar.gz"

function check_dir(){
  if [ -d "${TOMCAT8_PATH}" ];then
    echo "tomcat dir have exsits,please check..."
    exit 1
  else
    sleep 1
  fi
}

function tomcat8_down_install(){
 cd ${DIR} && wget -c ${TOMCAT8_DOWN_URL}
 tar -zxf ${TOMCAT8_VERSION}.tar.gz
 mv ${TOMCAT8_VERSION}/ ${TOMCAT8_PATH}
 #mv ${TOMCAT8_PATH}/conf/server.xml ${TOMCAT8_PATH}/conf/server.xml.default
 #cp ${DIR}/server.xml ${TOMCAT8_PATH}/conf/server.xml
 ${TOMCAT8_PATH}/bin/catalina.sh start
}

function main(){
  check_dir
  tomcat8_down_install
}
main

