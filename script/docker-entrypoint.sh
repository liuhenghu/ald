#!/bin/bash
set -e
#清理临时文件
rm -f /tmp/*.pid 
rm -f /tmp/*.sock
rm -f /www/mysql/data/mysql-slow.log
rm -f /www/mysql/data/mysql-error.log

if [[ ! -d "/tmp/php/session" ]]; then
    mkdir -p /tmp/php/session
    chown -R nginx.nginx /tmp/php/session
fi

if [[ ! -d "/tmp/php/wsdlcache" ]]; then
    mkdir -p /tmp/php/wsdlcache
    chown -R nginx.nginx /tmp/php/wsdlcache
fi

if [[ ! -d "/www/gm_data/log" ]]; then
    mkdir /www/gm_data/log
    chown -R nginx.nginx /www/gm_data
fi

cat > /etc/environment << EOF
PUBLIC_IP=${PUBLIC_IP}
DDNS_ENABLE=${DDNS_ENABLE}
DDNS_DOMAIN=${DDNS_DOMAIN}
EOF

#修改GM值
GM_CODE=$(echo "${GM_CODE}" | sed 's/"//g' | sed "s/'//g")
old_gmcode=$(awk -F"'" '/gmcodeb/ {print $2}' /www/wwwroot/game/public/gmht/user/config.php)
if [[ ${old_gmcode} != ${GM_CODE} ]]; then 
    sed -i "s/\(\$gmcodeb = '\)[^']*\(';.*\)/\1${GM_CODE}\2/" /www/wwwroot/game/public/gmht/user/config.php
fi
if [[ ! -f /etc/cron.d/update_mw ]]; then
    echo "*/10 * * * * root source /etc/environment && /script/update_mw.sh" > /etc/cron.d/update_mw
fi


#添加执行权限
chmod +x /root/s1/bin/*  
chmod +x /root/platform/bin/*


#初始化数据库
bash /script/init_db.sh

#修改IP地址
bash /script/update_ip.sh

#修改配置文件数据库信息
bash /script/update_database_info.sh

#修改monit配置文件

bash /script/update_monit.sh
chmod 700 /etc/monitrc

#启动redis
service redis-server start
#启动php
service php-fpm start
#启动node
service node start
#启动nginx
service nginx start
# #启动cron
service crond start


/bin/monit -I