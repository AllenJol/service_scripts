#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#Description: install nginx-1.12.2 for centos 6.x

CPU_CORE=`grep processor /proc/cpuinfo | wc -l`
DIR="/usr/local/src"
PCRE_VERSION="pcre-8.39"
PCRE_DOWN_URL="https://ftp.pcre.org/pub/pcre/${PCRE_VERSION}.tar.gz"
NGX_CACHE_PURGE_VERSION="ngx_cache_purge-2.3"
NGX_CACHE_PURGE_DOWN_URL="http://labs.frickle.com/files/${NGX_CACHE_PURGE_VERSION}.tar.gz"
NGINX_VERSION="nginx-1.12.2"
NGINX_DOWN_URL="http://nginx.org/download/${NGINX_VERSION}.tar.gz"

function check_root(){
	if [ $UID -ne 0 ];then
		echo -e "\e[1;35mMust be root to excute this script.\e[0m"
		exit 1
	fi
}
check_root

function create_user(){
	gflag=`cat  /etc/group  |awk -F':'  '{print  $1}'  | grep  www`
	[[ $gflag != "" ]]  && echo -e "\e[1;35mgroup 'www' already exists\e[0m"  || groupadd www
	uflag=`cat  /etc/passwd  |awk -F':'  '{print  $1}'  | grep  www`
	[[ $uflag != ""  ]] && echo -e "\e[1;35muser 'www' already exists\e[0m" || useradd -r www -g www -s /sbin/nologin
}
create_user

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
install_required_packages

function check_dir(){
	[ -f "/usr/local/nginx" ] && echo "There have nginx dir,scripts have been locked.make sure you don't install nginx first." && exit 1
}
check_dir

function pcre_download(){
	if [ -f "${DIR}/pcre-8.39.tar.gz" ];then
		echo "${PCRE_VERSION}.tar.gz exits."
		sleep 1
	else
		cd ${DIR} && wget -c ${PCRE_DOWN_URL}
	fi
}
pcre_download

function ngx_cache_purge_down(){
	if [ -f "${DIR}/${NGX_CACHE_PURGE_VERSION}.tar.gz" ];then
		echo "${NGX_CACHE_PURGE_VERSION}.tar.gz have exits,please clean it first." && exit 1
	else
		echo "Download ${NGX_CACHE_PURGE_VERSION}.tar.gz now!"
		cd ${DIR} && wget -c ${NGX_CACHE_PURGE_DOWN_URL}
	fi
}
ngx_cache_purge_down

function nginx_download(){
	if [ -f "${DIR}/${NGINX_VERSION}.tar.gz" ];then
    	echo "nginx packages is exists,clean your nginx package first."
    	exit 1
    else
    	echo -e "\e[1;34mDownload ${NGINX_VERSION} now,please wait...\e[0m"
    	cd ${DIR} && wget -c ${NGINX_DOWN_URL} && tar -zxf "${NGX_CACHE_PURGE_VERSION}.tar.gz"
    fi
}
nginx_download

function pcre_install(){
	cd ${DIR} && tar -zxf ${PCRE_VERSION}.tar.gz
	cd ${PCRE_VERSION}/ && ./configure >>/dev/null && make -j ${CPU_CORE} >>/dev/null && make install >>/dev/null
	[ $? -ne 0 ] && echo "编译pcre包出错，请检查！" && exit 1
}
pcre_install

function nginx_install(){
	echo -e "\e[1;34mInstall nginx now,please wait for a moments...\e[0m"
	cd ${DIR} && tar -zxf ${NGINX_VERSION}.tar.gz
	cd ${NGINX_VERSION}/
	./configure  --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-stream --with-stream_ssl_module --with-http_gzip_static_module --with-pcre=/usr/local/src/pcre-8.39 --add-module=/usr/local/src/ngx_cache_purge-2.3 >>/dev/null
	make -j ${CPU_CORE} >>/dev/null && make install >>/dev/null
}
nginx_install

function nginx_start(){
	echo "Enter [q or Q] to exit,Enter [s or S] to start nginx."
	read -p "Please enter your choice: " choice
case $choice in
q|Q)
	echo "Exit after 5 seconds." && sleep 5
	exit 1
	;;
s|S)
	echo "Start nginx now." && sleep 3 && /usr/local/nginx/sbin/nginx
	;;
esac
}
nginx_start

function check_nginx_status(){
	netstat -tunlp | grep nginx
	if [ $? -eq 0 ];then
		echo -e "\e[1;34mnginx start successfully and nginx version is:\e[0m"
		/usr/local/nginx/sbin/nginx -v
	else
		echo -e "\e[1;35mnginx start  failed ,please check\e[0m"
		exit 1
	fi
}
check_nginx_status
