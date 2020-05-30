#!/bin/bash
# write for visionguo
# history:2015.08.09 first
# 安装nginx

# 获取地址参数
tar_pwd=$PWD
ng_pwd=/usr/local/lnmp/nginx
my_pwd=/usr/local/lnmp/mysql
ph_pwd=/usr/local/lnmp/php

# 获取判断变量函数
panduan() {
	ls ${ng_pwd} &>/dev/null && ng_node=0 ||ng_node=1
	ls ${my_pwd} &>/dev/null && my_node=0 ||my_node=1
	ls ${ph_pwd}   &>/dev/null && ph_node=0 ||ph_node=1
}
panduan

# 安装状态列表函数
in_status_list() {
	echo "#########################################"
	echo -e "\033[36mlnmp架构安装情况:\033[0m"
        [ "$ng_node" != "0" ] && echo -e "\033[31mnginx is not install.\033[0m" ||echo -e "\033[32mnginx is installed.\033[0m"
        [ "$my_node" != "0" ] && echo -e "\033[31mmysql is not install.\033[0m" ||echo -e "\033[32mmysql is installed.\033[0m"
        [ "$ph_node" != "0" ] && echo -e "\033[31mphp is not install.\033[0m"  ||echo -e "\033[32mphp is installed.\033[0m"
}

# 安装选项列表函数
in_list(){
	echo "##############安装选项###################"
	echo -e "\033[36m可操作列表:\033[0m"
	[ "$ng_node" != "0" ] && echo -e "\033[32m	n:nginx安装 \033[0m"
	[ "$my_node" != "0" ] && echo -e "\033[33m	m:mysql安装 \033[0m"
	[ "$ph_node" != "0" ] && echo -e "\033[35m	p:php安装 \033[0m"
	echo -e "\033[34m        z:返回主列表\033[0m"
        echo -e "\033[34m        q:退出\033[0m"
}

# 安装选择函数
in_opt(){
	read -p "请选择(n|m|p|z|q)：" b
	if [ "$b" == "n" -a "$ng_node" != "0" ];then
		ng
	elif [ "$b" == "m" -a "$my_node" != "0" ];then
		my
	elif [ "$b" == "p" -a "$ph_node" != "0" ];then
		ph
        elif [ "$b" == "z" ];then
                list
                caozuo
        elif [ "$b" == "q" ];then
                exit
	else
		echo "别任性，看好选项和可以安装的软件！"
		in_opt
	fi
}


# nginx模块安装函数
ng(){
#        which wget &> /dev/null||yum install wget -y &>/dev/null
#        wget http://172.25.27.250/nginx-1.6.2.tar.gz &>/dev/null
	echo -e "\033[35m[0%]Nginx is installing... \033[0m"
	cd $tar_pwd
        tar zxf nginx-1.6.2.tar.gz
	echo -e "\033[32m[20%]Nginx is installing...\033[0m"
        yum install gcc pcre-devel openssl-devel -y &> /dev/null
	echo -e "\033[32m[30%]Nginx is installing...\033[0m"
        cd nginx-1.6.2
        ./configure --prefix=${ng_pwd} --with-http_ssl_module --with-http_stub_status_module &>/dev/null
	echo -e "\033[32m[60%]Nginx is installing...\033[0m"
        make &>/dev/null&& make install &>/dev/null
	echo -e "\033[32m[90%]Nginx is installing...\033[0m"
        grep nginx /etc/group &> /dev/null||groupadd -g 80 nginx
        id nginx &>/dev/null||useradd -u 80 -g 80 -d ${ng_pwd} -M nginx
        ln -s ${ng_pwd}/sbin/nginx /bin
	sed '2i user  nginx nginx;' ${ng_pwd}/conf/nginx.conf -i
	sed -i '14i use epoll;' ${ng_pwd}/conf/nginx.conf
	ng_node=0
	echo -e "\033[32m[100%]Installed is ok! \033[0m"
}

# mysql模块安装函数
my(){
	echo -e "\033[35m[0%]Mysql is installing... \033[0m"
	tar zxf mysql-5.5.12.tar.gz
	echo -e "\033[32m[10%]Mysql is installing...\033[0m"
	cd mysql-5.5.12
	yum install -y gcc gcc-c++ make ncurses-devel bison openssl-devel zlib-devel cmake &> /dev/null
	echo -e "\033[32m[20%]Mysql is installing...\033[0m"
	cmake -DCMAKE_INSTALL_PREFIX=${my_pwd} -DMYSQL_DATADIR=${my_pwd}/data -DMYSQL_UNIX_ADDR=${my_pwd}/data/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci &> /dev/null
	echo -e "\033[32m[55%]Mysql is installing...\033[0m"
	make &> /dev/null &&make install &> /dev/null
	echo -e "\033[32m[80%]Mysql is installing...\033[0m"
	cp ${my_pwd}/support-files/my-medium.cnf /etc/my.cnf
	cp ${my_pwd}/support-files/mysql.server /etc/init.d/mysqld
	echo "PATH=\$PATH:/usr/local/lnmp/mysql/bin" >> /etc/profile
	source /etc/profile
	grep mysql /etc/group &> /dev/null||groupadd -g 27 mysql &>/dev/null
	useradd -u 27 -g 27 -d ${my_pwd} -M mysql &> /dev/null
	chown mysql.mysql ${my_pwd} -R
	${my_pwd}/scripts/./mysql_install_db --user=mysql --basedir=${my_pwd} --datadir=${my_pwd}/data/ &>/dev/null
	echo -e "\033[32m[90%]Mysql is installing...\033[0m"
	my_node=0
	echo -e "\033[32m[100%]Installed is ok! \033[0m"
}

# php模块安装函数
ph(){
	echo -e "\033[35mPhp is installing... \033[0m"
	cd $tar_pwd 
	tar jxf php-5.4.36.tar.bz2
	echo -e "\033[32m[5%]Php is installing...\033[0m"
	yum install libmcrypt-2.5.8-9.el6.x86_64.rpm libmcrypt-devel-2.5.8-9.el6.x86_64.rpm gd-devel-2.0.35-11.el6.x86_64.rpm -y &>/dev/null
	echo -e "\033[32m[10%]Php is installing...\033[0m"
	cd php-5.4.36
	yum install net-snmp-devel curl-devel libxml2-devel libpng-devel libjpeg-devel freetype-devel gmp-devel openldap-devel -y &> /dev/null
	yum install gcc-c++ make ncurses-devel bison openssl-devel zlib-devel libxml2-devel easy-devel libcurl-devel-7.19.7-37.el6_4.x86_64 libjpeg-turbo-devel-1.2.1-1.el6.x86_64 gd-devel-2.0.35-11.el6.x86_64.rpm gmp-devel-4.3.1-7.el6_2.2.x86_64 net-snmp-devel expect php-pear.noarch -y &> /dev/null
	echo -e "\033[32m[30%]Php is installing...\033[0m"
	./configure --prefix=${ph_pwd} --with-config-file-path=${ph_pwd}/etc --with-mysql=${my_pwd} --with-openssl --with-snmp --with-gd --with-zlib --with-curl --with-libxml-dir --with-png-dir --with-jpeg-dir --with-freetype-dir --with-pear --with-gettext --with-gmp --enable-inline-optimization --enable-soap --enable-ftp --enable-sockets --enable-mbstring --with-mysqli=${my_pwd}/bin/mysql_config --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-ldap-sasl --with-mcrypt --with-mhash &>/dev/null
	echo -e "\033[32m[65%]Php is installing...\033[0m"
	make &> /dev/null && make install &>/dev/null
	echo -e "\033[32m[80%]Php is installing...\033[0m"
	/usr/bin/expect  &>/dev/null <<EOF
	spawn ${ph_pwd}/bin/php ${tar_pwd}/go-pear.phar
	send "\n"
	send "\n"
	expect eof
	exit
EOF
	cp ${tar_pwd}/php-5.4.36/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
	echo -e "\033[32m[90%]Php is installing...\033[0m"
	chmod +x /etc/init.d/php-fpm
	nginx
	cp ${tar_pwd}/php-5.4.36/php.ini-production ${ph_pwd}/etc/php.ini
	sed '909i date.timezone = Asia/Shanghai' ${ph_pwd}/etc/php.ini -i
	cp ${ph_pwd}/etc/php-fpm.conf.default ${ph_pwd}/etc/php-fpm.conf
	sed '25i pid = run/php-fpm.pid' ${ph_pwd}/etc/php-fpm.conf -i
	sed -i '66,73s/#//g' ${ng_pwd}/conf/nginx.conf
	sed -i 's/fastcgi_params/fastcgi.conf/g' ${ng_pwd}/conf/nginx.conf
	echo "<?php
phpinfo();
?>" > ${ng_pwd}/html/index.php
	/etc/init.d/php-fpm start
	echo -e "\033[32m[95%]Php is installing...\033[0m"
	nginx -s reload
	ph_node=0
	echo -e "\033[32m[100%]Installed is ok! \033[0m"
}

# 后台检测程序,只要有一个判断变量不等于0都会继续检测。
jiance() {
	while [ "$ng_node" != "0" -o "$my_node" != "0" -o "$ph_node" != "0" ]
	do
		sleep 5
	done
}
# 卸载列表模块
re_list() {
	echo "#################卸载####################"
        echo -e "\033[36m可选列表:\033[0m"
        [ "$ng_node" = "0" ] && echo -e "\033[32m	n:nginx卸载 \033[0m"
        [ "$my_node" = "0" ] && echo -e "\033[33m	m:mysql卸载 \033[0m"
        [ "$ph_node" = "0" ] && echo -e "\033[35m	p:php卸载 \033[0m"
	echo -e "\033[34m        z:返回主列表\033[0m"
	echo -e "\033[34m        q:退出\033[0m"
}
# 卸载模块
xiezai() {
	read -p "请选择(n|m|p|z|q)：" c
	if [ "$ng_node" = "0" -a "$c" = "n" ];then
		nginx -s stop &> /dev/null
		rm -f /bin/nginx &> /dev/null
		rm -rf $ng_pwd &> /dev/null
		ng_node=1
	elif [ "$my_node" = "0" -a "$c" = "m" ];then
		sed -i '79d' /etc/profile
		source /etc/profile &>/dev/null
		/etc/init.d/mysqld stop &> /dev/null
		rm -f /etc/my.cnf /etc/init.d/mysqld ${my_pwd} &> /dev/null
		rm -rf $my_pwd &> /dev/null
		my_node=1
	elif [ "$ph_node" = "0" -a "$c" = "p" ];then
		/etc/init.d/php-fpm stop &>/dev/null
		sed -i '66,73d' ${ng_pwd}/conf/nginx.conf &>/dev/null
		rm -f /etc/php.ini /etc/php-fpm.conf &> /dev/null
		rm -rf $ph_pwd &> /dev/null
		ph_node=1
	elif [ "$c" == "z" ];then
		list
		caozuo
	elif [ "$c" == "q" ];then
		exit
	else
		echo "别任性，看好选项和可以卸载的软件！"
		xiezai
	fi
}

# 服务选择列表函数	
se_list() {
        echo "#################服务列表####################"
        echo -e "\033[36m可选择服务列表:\033[0m"
        [ "$ng_node" = "0" ] && echo -e "\033[32m        n:nginx服务 \033[0m"
        [ "$my_node" = "0" ] && echo -e "\033[33m        m:mysql服务 \033[0m"
        [ "$ph_node" = "0" ] && echo -e "\033[35m        p:php服务 \033[0m"
        echo -e "\033[34m	z:返回主列表\033[0m"
        echo -e "\033[34m	q:退出\033[0m"
}
# 服务操作列表函数
se_caozuo_list() {
	echo -e "\033[36m可操作列表:\033[0m"
        echo -e "\033[32m      1.启动服务 \033[0m"
        echo -e "\033[33m      2.暂停服务 \033[0m"
        echo -e "\033[35m      3.卸载服务 \033[0m"
        echo -e "\033[35m      s.返回服务选择列表\033[0m"
        echo -e "\033[34m      z.返回主列表\033[0m"
        echo -e "\033[34m      q.退出\033[0m"
}

# 服务操作模块
se_caozuo() {
        read -p "请选择操作(1|2|3|s|z|q)：" b
        if [ "$b" == "1"  ];then
                echo "#################nginx##################"
        elif [ "$b" == "2"  ];then
                echo "#################mysql##################"
        elif [ "$b" == "3" ];then
                echo "#################php##################"
        elif [ "$b" == "s" ];then
		se_list
		se_opt
        elif [ "$b" == "z" ];then
                list
                caozuo
        elif [ "$b" == "q" ];then
                exit
        else
                echo "别任性，看好选项和可以执行的操作！"
                se_caozuo
        fi

}	
# 服务选择模块
se_opt() {
        read -p "请选择服务(n|m|p|z|q)：" b
        if [ "$b" == "n" -a "$ng_node" = "0" ];then
                echo "#################nginx##################"
		se_caozuo_list
		se_caozuo
        elif [ "$b" == "m" -a "$my_node" = "0" ];then
                echo "#################mysql##################"
		se_caozuo_list
		se_caozuo
        elif [ "$b" == "p" -a "$ph_node" = "0" ];then
                echo "#################php##################"
		se_caozuo_list
		se_caozuo
        elif [ "$b" == "z" ];then
                list
                caozuo
        elif [ "$b" == "q" ];then
                exit
        else
                echo "别任性，看好选项和可以用的服务！"
                se_opt
        fi

}
# 操作列表函数
list(){
	echo "#############主要操作列表################"
	 echo -e "\033[31m可执行操作：\033[0m"
	echo -e "\033[32m	1.安装软件 \033[0m
\033[33m	2.服务操作\033[0m
\033[34m	3.卸载 \033[0m
\033[34m	4.退出 \033[0m
\033[31m	5.修改安装路径 \033[0m"
}

# 操作模块
caozuo() {
#	echo "################选择操作###################"
	read -p "选择操作(1|2|3|4|5):" d
	if [ "$d" == "1" ];then
		in_status_list
		in_list
		in_opt
	elif [ "$d" == "2" ];then
		se_list
		se_opt
	elif [ "$d" == "3" ];then
		re_list
		xiezai
	elif [ "$d" == "4" ];then
		exit
	elif [ "$d" == "5" ];then
		echo "0.0，抱歉，功能尚未开发。。。"
		caozuo
	else
		echo "别任性，看好选项!"
		caozuo
	fi
}
# master程序
zhengwen(){
if [ "$ng_node" != "0" -a "$my_node" != "0" -a "$ph_node" != "0" ];then
	echo "#####################################"
	echo -e "\033[31mLnmp架构完全未安装\033[0m"
	read -p "是否快速安装完整架构(yes|no)：" a
	if [ "$a" == "yes" ];then
		ng &>/dev/null &
		my &>/dev/null &
		php &> /dev/null &
		jiance
		echo "Install is ok!"
	elif [ "$a" == "no" ];then
		in_status_list
		in_list
		in_opt
	else
		echo -e "\033[31m啥都没装你还瞎弄！\033[0m"
		exit
	fi
elif [ "$ng_node" != "0" -o "$my_node" != "0" -o "$ph_node" != "0" ];then
	in_status_list
	list
	caozuo
elif [ "$ng_node" == "0" ];then
        list
	caozuo
        read -p "输入'1|2|3':" i
        case "$i" in
                1)
                        nginx
                ;;
                2)
                        nginx -s stop &> /dev/null
                ;;
                3)
                        nginx -s stop &> /dev/null
                        rm -f /bin/nginx &> /dev/null
                      rm -rf ${ng_pwd} &> /dev/null
                ;;
                *)
                        echo "erro"
                ;;
        esac
fi
}


zhengwen


