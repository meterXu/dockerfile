FROM docker.io/98weiting09/nkas6.5
MAINTAINER isaac

RUN cd /etc/yum.repos.d \ 
&& wget -O CentOS-Base.repo http://192.168.12.105/zj/Centos-6.repo \
&& yum clean all \
&& rpm --rebuilddb \
&& TZ='Asia/Shanghai'; export TZ \
&& sed -i '$i /10 * * * * ntpdate ntp.api.bz' /etc/crontab \
&& yum install -y gcc wget tar apr-devel apr-util-devel pkgconfig expat-devel cyrus-sasl-devel openldap-devel zlib-devel pcre* libxml2* m4* autoconf* libjpeg* libpng-devel freetype-devel \

# apr
&& mkdir /data \
&& cd /data \
&& wget http://192.168.12.105/zj/apr-1.6.3.tar.gz \
&& tar zxvf apr-1.6.3.tar.gz \
&& cd apr-1.6.3 \
&& ./configure --prefix=/usr/local/apr && make && make install \

# apr-util
&& cd /data \
&& wget http://192.168.12.105/zj/apr-util-1.6.1.tar.gz \
&& tar xvzf apr-util-1.6.1.tar.gz \
&& cd apr-util-1.6.1 \
&& ./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr && make && make install \

# httpd
&& cd /data \
&& wget http://192.168.12.105/zj/httpd-2.4.29.tar.gz \
&& tar xvzf httpd-2.4.29.tar.gz \
&& cd httpd-2.4.29 \
&& ./configure --prefix=/usr/local/apache2 --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-pcre=/usr/local/pcre --enable-rewrite --enable-so --enable-headers --enable-expires --with-mpm=worker --enable-modules=most --enable-deflate && make && make install \
&& sed -i 's/#ServerName www.example.com:80/ServerName localhost/g' /usr/local/apache2/conf/httpd.conf \
&& ln -s /usr/local/apache2/bin/apachectl /etc/init.d/httpd \
&& service httpd restart \

# oracle-instantclient 
&& yum install -y libaio \
&& rpm -Uvh http://192.168.12.105/zj/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm \
&& rpm -Uvh http://192.168.12.105/zj/oracle-instantclient11.2-devel-11.2.0.2.0.x86_64.rpm \
&& rpm -Uvh http://192.168.12.105/zj/oracle-instantclient11.2-sqlplus-11.2.0.2.0.x86_64.rpm \

# php
&& cd /data \
&& wget http://192.168.12.105/zj/php-5.5.38.tar.gz \
&& tar xvzf php-5.5.38.tar.gz \
&& cd php-5.5.38 \
&& cp -frp /usr/lib64/libldap* /usr/lib/ \
&& ./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2/bin/apxs --enable-bcmath --enable-mbstring --enable-sockets --with-ldap --with-gettext && make && make install \
&& cp /data/php-5.5.38/php.ini-development /usr/local/php/lib/php.ini \
&& sed -i '151i LoadModule php5_module modules/libphp5.so' /usr/local/apache2/conf/httpd.conf \
&& sed -i '411i AddType application/x-httpd-php .php' /usr/local/apache2/conf/httpd.conf \
&& sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php/g' /usr/local/apache2/conf/httpd.conf \
&& service httpd restart \

# gd
&& cd /data/php-5.5.38/ext/gd \
&& /usr/local/php/bin/phpize \
&& ./configure --with-php-config=/usr/local/php/bin/php-config --with-jpeg-dir --with-png-dir --with-freetype-dir && make && make install \
&& echo "extension=gd.so" >>  /usr/local/php/lib/php.ini \
&& service httpd restart \

# oci8
&& cd /data \ 
&& wget http://192.168.12.105/zj/oci8-2.0.12.tgz \ 
&& tar zxvf oci8-2.0.12.tgz \ 
&& cd oci8-2.0.12 \ 
&& /usr/local/php/bin/phpize \ 
&& ./configure --with-oci8=shared,instantclient,/usr/lib/oracle/11.2/client64/lib --with-php-config=/usr/local/php/bin/php-config && make && make install \ 
&& echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf \ 
&& echo "extension=oci8.so" >> /usr/local/php/lib/php.ini \ 
&& service httpd restart \

# jetscan
&& yum install -y unixODBC unixODBC-devel net-snmp net-snmp-devel java-1.7.0-openjdk java-1.7.0-openjdk-devel openipmi unzip libxml2-devel OpenIPMI-devel pcre-devel \
&& rpm -Uvh http://192.168.12.105/zj/libssh2-1.4.2-2.el6_7.1.x86_64.rpm \
&& rpm -Uvh http://192.168.12.105/zj/libssh2-devel-1.4.2-2.el6_7.1.x86_64.rpm \
&& yum install -y libevent libevent-devel libevent-doc libevent-headers \
&& yum install -y curl-devel \
&& mkdir -p /usr/lib/oracle/11.2/client64/rdbms/public \
&& cp -r /usr/include/oracle/11.2/client64/* /usr/lib/oracle/11.2/client64/rdbms/public \
&& cd /data \
&& wget http://192.168.12.105/zj/jetscan-core.zip \
&& unzip jetscan-core.zip \
&& cd jetscan/code \
&& chmod +x ./configure \
&& ./configure --prefix=/home/jetscan --enable-server --enable-agent --enable-java --with-ssh2 --enable-ipv6 --with-oracle=/usr/lib/oracle/11.2/client64 --with-unixodbc  --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi && make && make install \
&& ln -s /home/jetscan/etc /etc/jetscan \
&& sed -i "s@;date.timezone =@date.timezone = Asia/Shanghai@g" /usr/local/php/lib/php.ini \
&& sed -i "s@max_execution_time = 30@max_execution_time = 300@g" /usr/local/php/lib/php.ini \
&& sed -i "s@post_max_size = 8M@post_max_size = 32M@g" /usr/local/php/lib/php.ini \
&& sed -i "s@max_input_time = 60@max_input_time = 300@g" /usr/local/php/lib/php.ini \
&& sed -i "s@memory_limit = 128M@memory_limit = 128M@g" /usr/local/php/lib/php.ini \
&& sed -i "s@;mbstring.func_overload = 0@ambstring.func_overload = 2@g" /usr/local/php/lib/php.ini \
&& sed -i "s@upload_max_filesize = 2M@upload_max_filesize = 32M@g" /usr/local/php/lib/php.ini \
&& cp /data/jetscan/code/misc/init.d/fedora/core5/zabbix_server /etc/init.d/jetscan_server \
&& cp /data/jetscan/code/misc/init.d/fedora/core5/zabbix_agentd /etc/init.d/jetscan_agentd \
&& sed -i "s@ZABBIX_BIN=\"/usr/local/sbin/zabbix_server\"@ZABBIX_BIN=\"/home/jetscan/sbin/zabbix_server\"@g" /etc/init.d/jetscan_server \
&& sed -i "s@ZABBIX_BIN=\"/usr/local/sbin/zabbix_agentd\"@ZABBIX_BIN=\"/home/jetscan/sbin/zabbix_agentd\"@g" /etc/init.d/jetscan_agentd \
&& chkconfig --add jetscan_server \
&& chkconfig --add jetscan_agentd \
&& chmod 700 /etc/init.d/jetscan_* \
&& mkdir -p /usr/local/apache2/htdocs/jetscan \
&& cp -prf /data/jetscan/code/frontends/php/* /usr/local/apache2/htdocs/jetscan \
&& chmod -R 777 /usr/local/apache2/htdocs/jetscan \
&& service httpd restart \
&& useradd zabbix \
&& service jetscan_server start \

# jetscan_config
&& mkdir /var/log/jetscan \
&& chmod 777 -R /var/log/jetscan \
&& sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/g' /etc/jetscan/zabbix_agentd.conf \
&& sed -i 's/LogFile=\/tmp\/zabbix_agentd.log/LogFile=\/var\/log\/jetscan\/jetscan_agentd.log/g' /etc/jetscan/zabbix_agentd.conf \
&& sed -i 's/Hostname=Zabbix server/Hostname=Jetscan server/g' /etc/jetscan/zabbix_agentd.conf \
&& sed -i 's/LogFile=\/tmp\/zabbix_server.log/LogFile=\/var\/log\/jetscan\/jetscan_server.log/g' /etc/jetscan/zabbix_server.conf \

# snmptrap
&& yum install -y net-snmp* \
&& cd /usr/bin \
&& wget http://192.168.12.105/zj/zabbix_trap_receiver.pl \
&& chmod +x /usr/bin/zabbix_trap_receiver.pl \
&& sed -i 's/\/tmp\/zabbix_traps.tmp/\/var\/log\/snmptrap\/snmptrap.log/g' /usr/bin/zabbix_trap_receiver.pl \
&& mkdir /var/log/snmptrap \
&& sed -i '$i authCommunity   log,execute,net public' /etc/snmp/snmptrapd.conf \
&& sed -i '$i perl do "/usr/bin/zabbix_trap_receiver.pl"' /etc/snmp/snmptrapd.conf \
&& sed -i 's/# SNMPTrapperFile=\/tmp\/zabbix_traps.tmp/SNMPTrapperFile=\/var\/log\/snmptrap\/snmptrap.log/g' /etc/jetscan/zabbix_server.conf \
&& sed -i 's/# StartSNMPTrapper=0/StartSNMPTrapper=1/g' /etc/jetscan/zabbix_server.conf \
&& snmptrapd -C -c /etc/snmp/snmptrapd.conf \

# fping
&& rpm -Uvh http://192.168.12.105/zj/fping-3.10-1.el6.rf.x86_64.rpm \
&& service jetscan_server restart \

# end
&& yum remove -y libevent-devel tar zip wget curl-devel php-devel libxml2-devel OpenIPMI-devel pcre-devel unixODBC-devel net-snmp-devel java-1.7.0-openjdk-devel apr-devel apr-util-devel expat-devel cyrus-sasl-devel openldap-devel zlib-devel libpng-devel freetype-devel \
&& yum clean metadata \
&& rm -rf /data \
&& sed -i '$i service httpd start' /etc/bashrc \
&& sed -i '$i service jetscan_server start' /etc/bashrc \
&& sed -i '$i service jetscan_agentd start' /etc/bashrc