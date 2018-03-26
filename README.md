一些常用的服务的脚本-centos6.x上亲测没问题：



1、mysql_binary_install.sh

说明：包括mysql-5.6.39和mysql-5.7.21的二进制包安装，会联网自动下载二进制包安装

2、nginx_install.sh

说明：nginx-1.12.2.tar.gz包 pcre-8.39.tar.gz ngx_cache_purge-2.3.tar.gz(第三方缓存)

3、php_install.sh

说明：php-5.6.34.tar.gz 和 php-7.2.3.tar.gz 选择安装

4、python_upgrade_to2.7.sh 和

说明：直接执行python_upgrade_to2.7.sh 会直接联网下载python2.7.13.tgz包进行安装并且调整yum

5、python_upgrade_to_2.7_or_3.6.sh

说明：直接执行会让你选择需要安装的版本:python-2.7.13或者python-3.6.4,并且会自动调整yum

6、supervisor_install.sh

说明：该脚本是安装supervisor，将某些无法后台启动的程序用supervisor以守护进程方式启动.
执行该脚本之前，我个人是升级了python到2.7.13，并安装了pip。supervisor目前只支持python2.x，不支持python3.x

7、shadowsocks_install.sh

说明：该脚本是在搬瓦工的vps机器或者在阿里云的国外服务器上搭建一个shadowsocks，即常说的小飞机，用于上google。
如果是阿里云服务器，一定要在服务器实例的安全组中打开8443端口，（我脚本中是用的8443，密码是shadowsocks.conf中YB开头的一大串）
我个人一般都是升级了python，然后安装了supervisor后，在执行这个脚本，将他拥supervisor作为守护进程启动。这样比较稳定

