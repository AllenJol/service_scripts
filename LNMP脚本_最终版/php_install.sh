#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#Description: install php-5.6.31 and php-7.1.15 for centos 6.x

CPU_CORE=`cat /proc/cpuinfo | grep "processor" | wc -l`
DIR="/usr/local/src"
PHP56_SOURCE="php-5.6.31"
PHP71_SOURCE="php-7.1.15"
PHP56_DOWN_URL="http://am1.php.net/distributions/${PHP56_SOURCE}.tar.gz"
PHP71_DOWN_URL="http://am1.php.net/distributions/${PHP71_SOURCE}.tar.gz"
function check_root(){
	if [ $UID -ne 0 ];then
		echo -e "\e[1;35mMust be root to excute this script.\e[0m"
		exit 1
	fi
}

function install_required_packages(){
	NETTEST=`ping -c 1 www.baidu.com >>/dev/null`
	if [ $? -eq 0 ];then
		echo -e "Install required packages,please wait...\t Or you can press \e[5;35m[ctrl+c]\e[0m to exit."
	    yum install -y gcc gcc-c++ make cmake automake autoconf gd file bison patch \
	    mlocate flex diffutils zlib zlib-devel pcre pcre-devel libjpeg libjpeg-devel \
	    libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc \
	    glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl \
	    curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel \
	    openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients \
	    openldap-servers openldap-devellibxslt-devel kernel-devel libtool-libs \
	    readline-devel gettext-devel libcap-devel php-mcrypt libmcrypt libmcrypt-devel \
	    mhash mhash-devl mcrypt mcrypt-devel recode-devel gmp-devel icu libxslt libxslt-devel >>/dev/null
	else
		echo -e "\e[1;35mnetwork is error,please check first.\e[0m"
		exit 1
	fi
}

function check_dir(){
	[ -f "/usr/local/php" ] && echo "There have php dir,scripts have been locked.make sure you don't install php first." && exit 1
	[ -f "/usr/local/php56" ] && echo "There have php56 dir,scripts have been locked.make sure you don't install php first." && exit 1
	[ -f "/usr/local/php5.6" ] && echo "There have php5.6 dir,scripts have been locked.make sure you don't install php first." && exit 1
}

function create_user_www(){
	gflag=`cat  /etc/group  |awk -F':'  '{print  $1}'  | grep  www`
	[[ $gflag != "" ]]  && echo -e "\e[1;35mgroup 'www' already exists\e[0m"  || groupadd www
	uflag=`cat  /etc/passwd  |awk -F':'  '{print  $1}'  | grep  www`
	[[ $uflag != ""  ]] && echo -e "\e[1;35muser 'www' already exists\e[0m" || useradd -r www -g www -s /sbin/nologin
}

function menu(){
	echo -e "\e[1;34m**************************************************************\e[0m"
cat<<EOF
Please choose  php  version  which  you want to install: 
  1:php-5.6.31
  2:php-7.1.15
EOF
	echo -e "\e[1;34m**************************************************************\e[0m"
}
function  php_version(){
	read -p  "please choose php  version that you  want to install:" flag
}
function php_download(){
case $flag in
1)
    VERSION="php-5.6.31"
	if [ -f "${DIR}/${PHP56_SOURCE}.tar.gz" ];then
    	echo "php56 packages is exists,clean your php56 package first."
    	exit 1
    else
    	echo -e "\e[1;34mDownload ${PHP56_SOURCE} now,please wait...\e[0m"
    	cd ${DIR} && wget -c ${PHP56_DOWN_URL} && tar -zxf "${PHP56_SOURCE}.tar.gz"
    fi
;;
2)
    VERSION="php-7.1.15"
    if [ -f "${DIR}/${PHP71_SOURCE}.tar.gz" ];then
    	echo "php71 packages is exists,clean your php71 package first."
    	exit 1
    else
    	echo -e "\e[1;34mDownload ${PHP71_SOURCE} now,please wait...\e[0m"
    	cd ${DIR} && wget -c ${PHP71_DOWN_URL} && tar -zxf "${PHP71_SOURCE}.tar.gz"
    fi
;;
*)
    echo -e "\e[1;35mPlease  input number 1 or 2,other is not valid\e[0m"
    php_download
    php_version
esac
}

function php_install(){
ldconfig
cp -frp /usr/lib64/libldap* /usr/lib/
case $VERSION in
"php-5.6.31")
echo -e "\e[1;34mConfig php56 now,please wait for a moment about \e[1;35m[10~20]\e[0m minutes...\e[0m"
sleep 3
cd ${DIR}/${PHP56_SOURCE}
./configure --prefix=/usr/local/php56 \
--with-config-file-path=/usr/local/php56/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-pdo-mysql=mysqlnd \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-opcache \
--with-gettext \
--enable-mbstring \
--with-iconv \
--with-mcrypt \
--with-mhash \
--with-openssl \
--enable-bcmath \
--enable-soap \
--with-libxml-dir \
--enable-pcntl \
--enable-shmop \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sockets \
--with-curl \
--with-zlib \
--enable-zip \
--with-bz2 \
--with-readline \
--with-mcrypt \
--with-gd \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--enable-xml \
--enable-discard-path \
--enable-magic-quotes \
--enable-safe-mode \
--enable-shmop \
--with-curlwrappers \
--enable-mbregex \
--enable-cgi \
--enable-force-cgi-redirect \
--enable-ftp \
--enable-gd-native-ttf \
--enable-pcntl \
--with-xmlrpc \
--without-pear \
--enable-session >>/dev/null
echo -e "Compeling php now ,please wait about (10~20 minutes):"
make -j ${CPU_CORE} >>/dev/null
if [ $? -eq 0 ];then
	echo "Configure php56 successfully." && sleep 2
else
	echo "Configure php56 Error,Please check it."
	exit 1
fi
make install >>/dev/null
if [ $? -eq 0 ];then
	echo "Configure php56 successfully." && sleep 2
else
	echo "Configure php56 Error,Please check it."
	exit 1
fi
#拷贝php配置文件、启动脚本等
\cp /usr/local/php56/etc/php-fpm.conf.default  /usr/local/php56/etc/php-fpm.conf
\cp /usr/local/src/php-5.6.31/php.ini-production  /usr/local/php56/etc/php.ini
\cp /usr/local/src/php-5.6.31/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
sed -ri -e 's#;date.timezone =#date.timezone = PRC#g' -e 's#;cgi.fix_pathinfo=1#cgi.fix_pathinfo=0#g' /usr/local/php56/etc/php.ini
sed -i '363 s@expose_php = On@expose_php = Off@g' /usr/local/php56/etc/php.ini
/etc/init.d/php-fpm start
;;
"php-7.1.15")
echo -e "\e[1;34mConfig php71 now,please wait for a moment about \e[1;35m[10~20]\e[0m minutes...\e[0m"
cd ${DIR}/${PHP71_SOURCE}/ 
./configure --prefix=/usr/local/php71 \
--with-config-file-path=/usr/local/php56/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-pdo-mysql=mysqlnd \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-opcache \
--with-gettext \
--enable-mbstring \
--with-iconv \
--with-mcrypt \
--with-mhash \
--with-openssl \
--enable-bcmath \
--enable-soap \
--with-libxml-dir \
--enable-pcntl \
--enable-shmop \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sockets \
--with-curl \
--with-zlib \
--enable-zip \
--with-bz2 \
--with-readline \
--with-mcrypt \
--with-gd \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--enable-xml \
--enable-discard-path \
--enable-magic-quotes \
--enable-safe-mode \
--enable-shmop \
--with-curlwrappers \
--enable-mbregex \
--enable-cgi \
--enable-force-cgi-redirect \
--enable-ftp \
--enable-gd-native-ttf \
--enable-pcntl \
--with-xmlrpc \
--without-pear \
--enable-session >>/dev/null
echo -e "Compeling php now ,please wait about (10~20 minutes):"
make -j ${CPU_CORE} >>/dev/null
if [ $? -eq 0 ];then
	echo "Configure php71 successfully." && sleep 2
else
	echo "Configure php71 Error,Please check it."
	exit 1
fi
make install >>/dev/null
if [ $? -eq 0 ];then
	echo "Configure php71 successfully." && sleep 2
else
	echo "Configure php71 Error,Please check it."
	exit 1
fi
#拷贝php配置文件、启动脚本等
\cp /usr/local/php71/etc/php-fpm.conf.default  /usr/local/php71/etc/php-fpm.conf
\cp /usr/local/src/php-7.1.15/php.ini-production  /usr/local/php71/etc/php.ini
\cp /usr/local/src/php-7.1.15/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
#php-7.x中多了一下这步，拷贝一份文件作为主机池文件
\cp /usr/local/php71/etc/php-fpm.d/www.conf.default  /usr/local/php71/etc/php-fpm.d/www.conf 
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
sed -ri -e 's#;date.timezone =#date.timezone = PRC#g' -e 's#;cgi.fix_pathinfo=1#cgi.fix_pathinfo=0#g' /usr/local/php56/etc/php.ini
sed -i '363 s@expose_php = On@expose_php = Off@g' /usr/local/php56/etc/php.ini
/etc/init.d/php-fpm start
;;
*) 
  echo "php version error,please check" && exit 1
;;
esac
}

function  main(){
check_root
install_required_packages
check_dir
create_user_www
menu
php_version
php_download
php_install
}
main

