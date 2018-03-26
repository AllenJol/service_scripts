#php-5.x编译参数
./configreu --prefix=/usr/local/php56 \
--with-config-file-path=/usr/local/php56/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
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
--enable-sysvshm \
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
--enable-fastcgi \
--enable-force-cgi-redirect \
--enable-ftp \
--enable-gd-native-ttf \
--with-openssl \
--enable-pcntl \
--with-xmlrpc \
--without-pear \
--enable-session >>/dev/null




""" 安装路径 """
--prefix=/usr/local/php56 \
""" php.ini 配置文件路径 """
--with-config-file-path=/usr/local/php56/etc \
""" FPM """
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
""" MySQL """
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
""" 优化选项 """
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
""" 启用 opcache，默认为 ZendOptimizer+(ZendOpcache) """
--enable-opcache \
""" 国际化与字符编码支持 """
--with-gettext \
--enable-mbstring \
--with-iconv \
""" 加密扩展 """
--with-mcrypt \
--with-mhash \
--with-openssl \
""" 数学扩展 """
--enable-bcmath \
""" Web 服务，soap 依赖 libxml """
--enable-soap \
--with-libxml-dir \
""" 进程，信号及内存 """
--enable-pcntl \
--enable-shmop \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
""" socket & curl """
--enable-sockets \
--with-curl \
""" 压缩与归档 """
--with-zlib \
--enable-zip \
--with-bz2 \
""" GNU Readline 命令行快捷键绑定 """
--with-readline




php-7.x编译参数（有些参数在5.x版本已经废除）
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
--enable-sysvshm \
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
--with-openssl \
--enable-pcntl \
--with-xmlrpc \
--without-pear \
--enable-session >>/dev/null

