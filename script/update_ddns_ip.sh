#!/bin/bash
source /etc/profile
DDNS_DOMAIN=$(echo "${DDNS_DOMAIN}" | sed 's/"//g' | sed "s/'//g")
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


ddns_ip=`dig +short ${DDNS_DOMAIN}`

if [[ -z ${ddns_ip} ]];then
    echo "The domain ${DDNS_DOMAIN} cannot be resolved, please enter the correct ENV:DDNS_DOMAIN"
    exit 1
fi

regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
if [[ $ddns_ip =~ $regex ]]; then
    IFS='.' read -r -a octets <<< "$ddns_ip"
    for octet in "${octets[@]}"; do
        if ((octet < 0 || octet > 255)); then
            echo "$ddns_ip is not compliant, please check ${DDNS_DOMAIN} resolution"
            exit 1
        fi
    done
else
    echo "$ddns_ip is not compliant, please check ${DDNS_DOMAIN} resolution"
    exit 1
fi
echo "DDNS_DOMAIN IP is ${ddns_ip}"

now_ip=$(awk -F '=' '/ip/ {print $2}'  /root/platform/RelayServer/RelayServer.cfg | sed 's/[\r\n]//g')
echo "The current IP is ${now_ip}"
if [[ ${ddns_ip} != ${now_ip} ]];then
    echo "Changing the current IP to ${ddns_ip}"
    cp -r /file/*  /root/
    for i in ${file_list[@]};
    do
        if [[ ${i} == "/root/s1/AdminServer/AdminServer.cfg" ]] || [[ ${i} == "/root/platform/CenterServer/CenterServer.cfg" ]]; then
            sed -i s/192.168.1.200/${DDNS_DOMAIN}/g $i
        elif [[ ${i} == "/root/s1/SceneServer/SceneServer.cfg" ]];then
            sed -i s/192.168.1.200/${DDNS_DOMAIN}/g $i
        else
            sed -i s/192.168.1.200/${ddns_ip}/g $i
        fi
    done
    mysql -uroot -D ald_web -e "update tk_gameconfig set ip = '$ddns_ip'"
    mysql -uroot -D demoald -e "update xy_gameconfig set ip = '$ddns_ip'"

    monit_num=$(ps -ef  |grep -v grep |grep monit |wc -l)
    if [[ ${monit_num} -eq 1 ]]; then
        monit restart all
    fi
fi

