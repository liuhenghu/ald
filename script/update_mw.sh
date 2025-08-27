#!/bin/bash

DDNS_ENABLE=$(echo "${DDNS_ENABLE}" | sed 's/"//g' | sed "s/'//g")
if [[ ${DDNS_ENABLE} == "true" ]]; then
    DDNS_DOMAIN=$(echo "${DDNS_DOMAIN}" | sed 's/"//g' | sed "s/'//g")
    curl  http://${DDNS_DOMAIN}:81/mw_rank/index/update?key=aldmwupdate666
elif [[ ${DDNS_ENABLE} == "false" ]]; then  
    PUBLIC_IP=$(echo "${PUBLIC_IP}" | sed 's/"//g' | sed "s/'//g")
    curl  http://${PUBLIC_IP}:81/mw_rank/index/update?key=aldmwupdate666
fi

