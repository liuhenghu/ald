#!/bin/bash
source /etc/profile
export TZ=Asia/Shanghai
current_dir=$(pwd)
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
    if [[ ${current_dir} == "/root" ]];then
        echo "$(date +'%F %T')The domain ${DDNS_DOMAIN} cannot be resolved, please enter the correct ENV:DDNS_DOMAIN" > /proc/1/fd/1
    else
        echo "$(date +'%F %T')The domain ${DDNS_DOMAIN} cannot be resolved, please enter the correct ENV:DDNS_DOMAIN"
    fi
    exit 1
fi

regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
if [[ $ddns_ip =~ $regex ]]; then
    IFS='.' read -r -a octets <<< "$ddns_ip"
    for octet in "${octets[@]}"; do
        if ((octet < 0 || octet > 255)); then
            if [[ ${current_dir} == "/root" ]];then
                echo "$(date +'%F %T')$ddns_ip is not compliant, please check ${DDNS_DOMAIN} resolution" > /proc/1/fd/1
            else
                echo "$(date +'%F %T')$ddns_ip is not compliant, please check ${DDNS_DOMAIN} resolution"
            fi
            exit 1
        fi
    done
else
    if [[ ${current_dir} == "/root" ]];then
        echo "$(date +'%F %T')$ddns_ip is not compliant, please check ${DDNS_DOMAIN} resolution" > /proc/1/fd/1
    else
        echo "$(date +'%F %T')$ddns_ip is not compliant, please check ${DDNS_DOMAIN} resolution"
    fi
    exit 1
fi
if [[ ${current_dir} == "/root" ]];then
    echo "$(date +'%F %T')The domain ${DDNS_DOMAIN} resolved IP is ${ddns_ip}" > /proc/1/fd/1
else
    echo "$(date +'%F %T')The domain ${DDNS_DOMAIN} resolved IP is ${ddns_ip}"
fi

now_ip=$(awk -F '=' '/ip/ {print $2}'  /root/platform/RelayServer/RelayServer.cfg | sed 's/[\r\n]//g')

if [[ $current_dir == "/root" ]];then
    echo "$(date +'%F %T')The current IP is ${now_ip}" > /proc/1/fd/1
else
    echo "$(date +'%F %T')The current IP is ${now_ip}"
fi

if [[ ${ddns_ip} != ${now_ip} ]];then
    if [[ ${current_dir} == "/root" ]];then
        echo "$(date +'%F %T')Changing the current IP to ${ddns_ip}" > /proc/1/fd/1
    else
        echo "$(date +'%F %T')Changing the current IP to ${ddns_ip}"
    fi
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
        if [[ ${current_dir} == "/root" ]];then
            echo "$(date +'%F %T')Restarting all services through monit" > /proc/1/fd/1
        else
            echo "$(date +'%F %T')Restarting all services through monit"
        fi
        monit restart all
    fi
fi

