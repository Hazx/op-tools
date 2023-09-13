#!/bin/bash

## 环境变量
source /op-tools/env
MYSQL_ADDR_R=${MYSQL_ADDR:-localhost}
MYSQL_PORT_R=${MYSQL_PORT:-3306}
MYSQL_USER_R=${MYSQL_USER:-root}
MYSQL_PW_R=${MYSQL_PW:-root}
MYSQL_DB_R=${MYSQL_DB:=_ALL_}
MYSQL_BK_RETAIN_R=${BK_RETAIN:-14}


## 备份 MySQL 数据库
date_tag=$(date +%Y%m%d-%H%M)
if [[ $MYSQL_DB_R == "_ALL_" ]];then
    mysqldump -h ${MYSQL_ADDR_R} -P ${MYSQL_PORT_R} -u${MYSQL_USER_R} -p"${MYSQL_PW_R}" -A > /mnt/mysql__all__${date_tag}.sql 2>/dev/null
else
    mysqldump -h ${MYSQL_ADDR_R} -P ${MYSQL_PORT_R} -u${MYSQL_USER_R} -p"${MYSQL_PW_R}" ${MYSQL_DB_R} > /mnt/mysql_${MYSQL_DB_R}_${date_tag}.sql 2>/dev/null
fi

## 打包压缩
cd /mnt
ls *.sql| xargs -I {} zip -r {}.zip {}
rm -f *.sql

## 清理过时的备份数据
cd /mnt
if [[ $MYSQL_DB_R == "_ALL_" ]];then
    bk_num=$(ls -Art mysql__all__*.sql.zip | wc -l)
else
    bk_num=$(ls -Art mysql_${MYSQL_DB_R}_*.sql.zip | wc -l)
fi
if [[ $bk_num -gt ${MYSQL_BK_RETAIN_R} ]];then
    if [[ $MYSQL_DB_R == "_ALL_" ]];then
        find /mnt/ -name "mysql__all__*.sql.zip" | sort -r | sed -e 1,${MYSQL_BK_RETAIN_R}d | xargs -I {} rm -f {}
    else
        find /mnt/ -name "mysql_${MYSQL_DB_R}_*.sql.zip" | sort -r | sed -e 1,${MYSQL_BK_RETAIN_R}d | xargs -I {} rm -f {}
    fi
fi




