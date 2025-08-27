#!/bin/bash

PUBLIC_IP=$(echo "${PUBLIC_IP}" | sed 's/"//g' | sed "s/'//g")
file_list=(
/root/platform/CenterServer/CenterServer.cfg
/root/platform/RelayServer/RelayServer.cfg
/root/platform/RelayServer1/RelayServer.cfg
/root/platform/UdpConnServer/UdpConnServer.cfg
/root/platform/UdpConnServer1/UdpConnServer.cfg
/root/platform/Config/UdpServer.xml
/root/s1/AdminServer/AdminServer.cfg
/root/s1/AdminServer/NetAddress.xml
/root/s1/Config/UdpServer.xml
/root/s1/SceneServer/SceneServer.cfg
)

regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
if [[ ${PUBLIC_IP} =~ $regex ]]; then
    IFS='.' read -r -a octets <<< "${PUBLIC_IP}"
    for octet in "${octets[@]}"; do
        if ((octet < 0 || octet > 255)); then
            echo "${PUBLIC_IP} is not compliant, please check PUBLIC_IP"
            exit 1
        fi
    done
else
    echo "${PUBLIC_IP} is not compliant, please check PUBLIC_IP"
    exit 1
fi

cp -r /file/*  /root/
for i in ${file_list[@]};
do
    sed -i s/192.168.1.200/${PUBLIC_IP}/g $i
done
mysql -uroot -D ald_web -e "update tk_gameconfig set ip = '${PUBLIC_IP}'"
mysql -uroot -D demoald -e "update xy_gameconfig set ip = '${PUBLIC_IP}'"

now_domain=$(awk '/server_name/ && !/\$server_name/ {print $2}' /etc/nginx/conf.d/default.conf | sed -e s/\;//)
if [[ ${now_domain} != ${PUBLIC_IP} ]];then
    sed -i  "4s/.*server_name.*/    server_name ${DDNS_DOMAIN};/" /etc/nginx/conf.d/default.conf
fi