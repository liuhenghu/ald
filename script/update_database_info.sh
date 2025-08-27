#!/bin/bash



sed -i "s|passwd=\"[^\"]*\"|passwd=\"${DB_ROOT_PASSWORD}\"|" /root/platform/GlobalActivityRecord/Database.xml
sed -i "s|passwd=\"[^\"]*\"|passwd=\"${DB_ROOT_PASSWORD}\"|" /root/platform/ReplayRecord/Database.xml
sed -i "s|passwd=\"[^\"]*\"|passwd=\"${DB_ROOT_PASSWORD}\"|" /root/platform/ReplayServer/Database.xml
sed -i "s|passwd=\"[^\"]*\"|passwd=\"${DB_ROOT_PASSWORD}\"|" /root/platform/TeamCopyRecord/Database.xml
sed -i "s|passwd=\"[^\"]*\"|passwd=\"${DB_ROOT_PASSWORD}\"|" /root/platform/UnionRecord/Database.xml
sed -i "s|passwd=\"[^\"]*\"|passwd=\"${DB_ROOT_PASSWORD}\"|" /root/s1/Database.xml


sed -i "s/.*db_passwd.*/db_passwd=${DB_ROOT_PASSWORD}/" /root/platform/CenterServer/CenterServer.cfg
sed -i "s/.*db_passwd.*/db_passwd=${DB_ROOT_PASSWORD}/" /file/platform/CenterServer/CenterServer.cfg
sed -i "s/.*db_passwd.*/db_passwd=${DB_ROOT_PASSWORD}/" /root/platform/BattleServer/BattleServer.cfg
sed -i "s/.*db_passwd.*/db_passwd=${DB_ROOT_PASSWORD}/" /root/platform/CrossServer/CrossServer.cfg

sed -i "s|.*'password'.*|    'password'        => '${DB_ROOT_PASSWORD}',|" /www/wwwroot/game/application/database.php
sed -i "s|.*'db_pswd'.*|\t\t\t'db_pswd'=>'${DB_ROOT_PASSWORD}',|" /www/wwwroot/game/public/gmht/user/config.php