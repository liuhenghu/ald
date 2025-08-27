#!/bin/bash
# 是否需要初始化
source /etc/profile
export DB_ROOT_PASSWORD=$(echo "${DB_ROOT_PASSWORD}" | sed 's/"//g' | sed "s/'//g")
sed -i "s/.*password.*/password\ =\ ${DB_ROOT_PASSWORD}/" /etc/my.cnf
if [ ! -d "/www/mysql/data/" ];then
    echo "prepare to init local mysql data....."
    # 清理数据
    rm -rf /www/mysql/*
    # 初始化mysql
    mysql_install_db --user=mysql > /dev/null 2>&1 
        # 修改创建root账号
    service mysql start --skip-grant-tables
    mysql -u root <<EOF
        delete from mysql.user;
        flush privileges;
        grant all privileges on *.* to 'root'@'%' identified by '$DB_ROOT_PASSWORD' WITH GRANT OPTION;
        flush privileges;
EOF
    echo "update root password done."
    # 关闭服务
    service mysql stop
else
    echo "local mysql data already inited."
fi

if [ ! -f /tmp/mysqld.pid ];then
    echo "start mysql...."
    service mysql start
fi

mysql -uroot -e "status" >dev/null 2>&1
check_passord=`echo $?`
if [[ $check_passord != 0 ]];then
    service mysql stop
    service mysql start --skip-grant-tables 
    mysql -uroot <<EOF 
        use mysql;
        update user set password=password('$DB_ROOT_PASSWORD') where user='root';
        flush privileges;
EOF
    echo "update root password done."
    # 关闭服务
    service mysql stop
fi
if [ ! -f /tmp/mysqld.pid ];then
    echo "start mysql...."
    service mysql start
fi
#初始化数据库数据
cd /root
bash sk