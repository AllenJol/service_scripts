#!/bin/bash
#__Author__: Allen_Jol
#__Date__: 2017-11-01

#新centos7系统做一些初始操作准备
function prepare(){
yum clean all && yum makecache
yum -y install python-pip
pip install --upgrade pip
}

function change_pip_source(){
if [ -f "/root/.pip/pip.conf" ];then
mv /root/.pip/pip.conf /root/.pip/pip.conf.bak
echo "">/root/.pip/pip.conf
cat>>/root/.pip/pip.conf<<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
else
mkdir -p /root/.pip/
cat>>/root/.pip/pip.conf<<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
fi
}

#开始安装依赖、supervisor、小飞机shadowsocks
function install_ss_super(){
pip install pyopenssl ndg-httpsclient
pip install shadowsocks
pip install supervisor
echo_supervisord_conf > /etc/supervisord.conf
mkdir -p /etc/supervisor/conf.d/
sed -i 's@\;\[include\]@\[include\]@g' /etc/supervisord.conf
sed -i 's@\;files \= relative\/directory\/\*\.ini@files \= \/etc\/supervisor\/conf.d\/\*\.conf@g' /etc/supervisord.conf
supervisord -c /etc/supervisord.conf
echo "/usr/bin/supervisord -c /etc/supervisord.conf" >>/etc/rc.local
}

#创建小飞机shadowsocks客户端验证的配置文件
function ss_config(){
cat >/etc/shadowsocks.json<<EOF
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

#创建用于supervisor管理的配置文件
function super_cofig(){
cat >/etc/supervisor/conf.d/ssserver.conf<<EOF
[program:ssserver]
command=/usr/bin/ssserver -c /etc/shadowsocks.json 
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
}

function ss_start(){
/usr/bin/supervisorctl reread
/usr/bin/supervisorctl update
}

function main(){
prepare
change_pip_source
install_ss_super
ss_config
super_cofig
ss_start
}
main
