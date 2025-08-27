#!/bin/bash

#修改IP地址
DDNS_ENABLE=$(echo "${DDNS_ENABLE}" | sed 's/"//g' | sed "s/'//g")
if [[ ${DDNS_ENABLE} == "true" ]]; then
    if [[ -n ${DDNS_DOMAIN} ]]; then
        DDNS_DOMAIN=$(echo "${DDNS_DOMAIN}" | sed 's/"//g' | sed "s/'//g")
        now_domain=$(awk '/server_name/ && !/\$server_name/ {print $2}' /etc/nginx/conf.d/default.conf | sed -e s/\;//)
        if [[ $now_domain != $DDNS_DOMAIN ]];then
            sed -i  "4s/.*server_name.*/    server_name ${DDNS_DOMAIN};/" /etc/nginx/conf.d/default.conf
        fi
        echo "Use DDNS_DOMAIN,The DDNS_DOMAIN is ${DDNS_DOMAIN}"
        echo "*/10 * * * * root source /etc/environment && /script/update_ddns_ip.sh" > /etc/cron.d/update_ddns_ip
        chmod 644 /etc/cron.d/update_ddns_ip
        bash /script/update_ddns_ip.sh
    else
        echo "Please set ENV DDNS_DOMAIN, example: 'www.baidu.com'"
    fi
elif [[ ${DDNS_ENABLE} == "false" ]]; then  
    if [[ -n ${PUBLIC_IP} ]]; then
        PUBLIC_IP=$(echo "${PUBLIC_IP}" | sed 's/"//g' | sed "s/'//g")
        echo "Use PUBLIC_IP, The PUBLIC_IP is ${PUBLIC_IP}"
        if [[ -f /etc/cron.d/update_ddns_ip ]];then
            rm -f /etc/cron.d/update_ddns_ip
        fi
        bash /script/update_public_ip.sh
    else
        echo "Please set ENV PUBLIC_IP, example: '192.168.1.200'"
    fi
elif [[ -z ${DDNS_ENABLE} ]]; then
    echo "Please set ENV DDNS_ENABLE to 'true' or 'false'"
else
    echo "Invalid value for ENV DDNS_ENABLE: '${DDNS_ENABLE}'. Please set it to 'true' or 'false'."
fi