FROM centos:7.9.2009

#安装基础软件包
COPY base/ /
RUN yum install -y  bind-utils wget yum-utils psmisc sysvinit-tools cronie initscripts && \
    rm -f /lib/systemd/system/crond.service  && yum clean all && rm -rf /var/cache/yum

#安装GCC5.2
RUN yum install /root/compat-libgmp-4.3.1-1.sl7.x86_64.rpm /root/compat-libmpfr-2.4.1-1.sl7.x86_64.rpm -y && \
    yum install devtoolset-4-gcc devtoolset-4-gcc-c++ devtoolset-4-binutils -y && \
    echo "source /opt/rh/devtoolset-4/enable" >> /etc/profile && source /etc/profile && \
    yum clean all && rm -rf /var/cache/yum

#安装redis
RUN wget https://rpmfind.net/linux/remi/enterprise/7/remi/x86_64/redis-5.0.14-1.el7.remi.x86_64.rpm && \
    yum install -y redis-5.0.14-1.el7.remi.x86_64.rpm && rm -f redis-5.0.14-1.el7.remi.x86_64.rpm && \
    rm -f /lib/systemd/system/redis.service && rm -f /lib/systemd/system/redis-sentinel.service && \
    sed -i 's/.*daemonize.*/daemonize\ yes/' /etc/redis.conf && \
    yum clean all && rm -rf /var/cache/yum
    
#安装mysql
RUN wget https://downloads.mysql.com/archives/get/p/23/file/MySQL-server-5.6.51-1.el7.x86_64.rpm && \
    wget https://downloads.mysql.com/archives/get/p/23/file/MySQL-client-5.6.51-1.el7.x86_64.rpm && \
    wget https://downloads.mysql.com/archives/get/p/23/file/MySQL-shared-5.6.51-1.el7.x86_64.rpm && \
    yum remove mariadb* && yum install -y MySQL-* && rm -f MySQL-*  && rm -rf /var/lib/mysql/* && \
    yum clean all && rm -rf /var/cache/yum

# php安装
RUN yum -y install php-cli php-fpm php-mysql php-mbstring php-xml php-curl php-gd php-opcache php-redis && \
    rm -f /lib/systemd/system/php-fpm.service && yum clean all && rm -rf /var/cache/yum

#安装nodejs
RUN wget https://nodejs.org/download/release/v14.17.6/node-v14.17.6-linux-x64.tar.gz && \
    tar -xzf node-v14.17.6-linux-x64.tar.gz && rm -f node-v14.17.6-linux-x64.tar.gz && \
    mv node-v14.17.6-linux-x64 /usr/local/nodejs  && echo "NODE_HOME=/usr/local/nodejs" >> /etc/profile && \
    echo "PATH=\$NODE_HOME/bin:\$PATH" >> /etc/profile && source /etc/profile && node -v 

#安装nginx
RUN yum install -y  nginx  && rm -f /lib/systemd/system/nginx.service  && \
    mkdir /tmp/nginx/proxy_temp_dir -p  && chown -R nginx.nginx /tmp/nginx && \
    yum clean all && rm -rf /var/cache/yum


#安装monit
RUN yum install monit -y && echo -e '#!/bin/bash\nexit 0' > /bin/systemctl && \
    yum clean all && rm -rf /var/cache/yum


#添加游戏文件
# COPY ald/file /file
# COPY ald/root /root
# COPY  --chown=nginx:nginx ald/www /www
RUN cd / && wget https://github.com/liuhenghu/ald/releases/download/base/file.tar.gz && \
    wget https://github.com/liuhenghu/ald/releases/download/base/root.tar.gz && \
    wget https://github.com/liuhenghu/ald/releases/download/base/www.tar.gz  && \
    tar -xzf file.tar.gz && tar -xzf root.tar.gz && tar -xzf www.tar.gz && \
    chown -R nginx:nginx /www && \
    rm -f www.tar.gz file.tar.gz root.tar.gz
#添加启动脚本
COPY init.d/ /etc/rc.d/init.d/
#添加mysql配置
COPY mysql/  /
#添加php配置
COPY php/ /
#添加nginx配置
COPY nginx/  /
#添加monit配置
COPY monit/  /

#添加执行脚本
COPY script /script
RUN  chmod +x /script/* && chmod +x /etc/rc.d/init.d/* && chmod +x /usr/lib64/php/modules/ixed.7.1.lin 

#暴露端口
EXPOSE 81/tcp 2812/tcp 3306/tcp 21007/tcp 21010/tcp 30702/tcp 31401/udp 31402/udp
#挂载卷
VOLUME ["/www/mysql", "/www/gm_data"]
#环境变量
ENV PUBLIC_IP=''
ENV DB_ROOT_PASSWORD='Ald123456'
ENV MONIT_USER=admin
ENV MONIT_PASS=123456
ENV GM_CODE=gm123456
# 默认关闭DDNS
ENV DDNS_ENABLE=false
ENV DDNS_DOMAIN=''



ENTRYPOINT [ "/script/docker-entrypoint.sh" ]