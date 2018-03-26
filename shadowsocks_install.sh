#!/bin/bash
#__Author__:Allen_Jol at 2018-03-26 23:58:34
#Description: 在搬瓦工vps或者阿里云国外服务器上安装shadowsocks小飞机。win/mac通过客户端拨号上google

function check_root(){
  if [ $UID -ne 0 ];then
    echo -e "\e[1;35mMust be root to excute this script.\e[0m"
    exit 1
  fi
}
check_root

function shadowsocks_install(){
PIP=`pip -V | awk '{print $1"-"$2}' | wc -l`
  if [ $PIP -eq 0 ];then
    echo "please install pip first" && exit 1
  else
    pip install pyopenssl ndg-httpsclient
    pip install shadowsocks
  fi
}

function shadowsocks_config(){
cat>>/etc/shadowsocks.json<<EOF
{
    "server":"0.0.0.0",                 
    "server_port":8443,                 
    "local_address":"127.0.0.1",        
    "local_port":1080,                  
    "password":"YB2saizt8J5de9MO",      
    "timeout":600,                     
    "method":"aes-256-cfb"  
}
EOF
}

function ssserver_config(){
if [ ! -d "/etc/supervisor/conf.d/" ];then
  echo "没有找到supervisor路径，请检查是否已安装supervisor."
else
cat>>/etc/supervisor/conf.d/ssserver.conf<<EOF
[program:ssserver]
command=/usr/local/python2.7/bin/ssserver -c /etc/shadowsocks.json 
numprocs=1
autostart=true
autorestart=true
startretries=10
stopsignal=QUIT
stopwaitsecs=10
user=root
directory=/usr/local/bin
redirect_stderr=true
stdout_logfile=/var/log/ssserver.log
stdout_logfile_maxbytes=100MB
stdout_logfile_backups=1
EOF
fi
}

function start_shadowsocks(){
  /usr/local/python2.7/bin/supervisorctl reread
  /usr/local/python2.7/bin/supervisorctl update
}

function check_super_status(){
  STATUS=`ps -ef | grep ssserver | grep -v "grep" | wc -l`
  if [ $STATUS -eq 0 ];then
    echo "shadowsocks start Failed,please check..."
    exit 1
  else
   echo "shadowsocks start Successfull,Congratulations"
  fi
}

function main(){
shadowsocks_install
shadowsocks_config
ssserver_config
start_shadowsocks
check_super_status
}
main
