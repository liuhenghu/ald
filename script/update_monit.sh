#!/bin/bash

TMP_MONIT_USER=$(awk -F '[ :"]+' '/allow/ && !/0\.0\.0\.0/ {print $3}' /etc/monitrc)
TMP_MONIT_PASS=$(awk -F '[ :"]+' '/allow/ && !/0\.0\.0\.0/ {print $4}' /etc/monitrc)
MONIT_USER=$(echo "${MONIT_USER}" | sed 's/"//g' | sed "s/'//g")
MONIT_PASS=$(echo "${MONIT_PASS}" | sed 's/"//g' | sed "s/'//g")
if [[ "${MONIT_USER}" != "${TMP_MONIT_USER}" ]] || [[ "${MONIT_PASS}" != "${TMP_MONIT_PASS}" ]]; then
    cp /etc/monitrc_tmp /etc/monitrc
    sed -i "s/.*allow admin:.*/    allow \"${MONIT_USER}\":\"${MONIT_PASS}\"/" /etc/monitrc
fi