#!/bin/bash

## 存储环境变量
rm -f /op-tools/env
env | grep -v _= > /op-tools/env-tmp
# cat /proc/1/environ | tr '\0' '\n' | grep -v _= > /op-tools/env-tmp
while read line; do
    var_name=${line%%=*}
    var_value=${line#*=}
    if [[ $var_value != \"*\" ]]; then
      var_value="\"$var_value\""
    fi
    echo "export $var_name=$var_value" >> /op-tools/env
done < /op-tools/env-tmp
rm -f /op-tools/env-tmp

## 修改 ROOT 密码
echo "${SET_PWD:-"wpuU2gurjYFLyBq"}" | passwd --stdin root

## 创建 SSH 秘钥 & 配置权限
rm -f /etc/ssh/ssh_host_ecdsa_key
rm -f /etc/ssh/ssh_host_ed25519_key
rm -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
chown root:ssh_keys /etc/ssh/ssh_host_ecdsa_key
chown root:ssh_keys /etc/ssh/ssh_host_ed25519_key
chown root:ssh_keys /etc/ssh/ssh_host_rsa_key
chmod 640 /etc/ssh/ssh_host_ecdsa_key
chmod 640 /etc/ssh/ssh_host_ed25519_key
chmod 640 /etc/ssh/ssh_host_rsa_key

## Oracle 注册
sh -c "echo /usr/lib/oracle/12.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf"
ldconfig

## 启用 SSH 服务
RUN_SSH_R=${RUN_SSH:-false}
if [[ $RUN_SSH_R == true ]];then
    /usr/sbin/sshd -D &
    RUN_KEEP=true
fi

## MySQL 备份
if [[ $1 == "bkmysql" ]];then
bash /op-tools/bk_mysql.sh
fi
if [[ ${BK_CROND_MODE} == "mysql" ]] && [[ ${BK_CROND_TIME} ]];then
    echo -e "\n${BK_CROND_TIME} root /op-tools/bk_mysql.sh\n" >> /etc/crontab
fi

## MongoDB 备份
if [[ $1 == "bkmongo" ]];then
bash /op-tools/bk_mongo.sh
fi
if [[ ${BK_CROND_MODE} == "mongo" ]] && [[ ${BK_CROND_TIME} ]];then
    echo -e "\n${BK_CROND_TIME} root /op-tools/bk_mongo.sh\n" >> /etc/crontab
fi

## 启用 crontab 定时任务
RUN_CROND_R=${RUN_CROND:-false}
if [[ $RUN_CROND_R == true ]];then
    cat /op-tools/crontab-list | grep -E -v "^#" >> /etc/crontab
    /usr/sbin/crond
    RUN_KEEP=true
fi

## 容器保活
RUN_KEEP_R=${RUN_KEEP:-false}
if [[ $RUN_KEEP_R == true ]];then
    /op-tools/keep
fi
