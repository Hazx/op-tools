#!/bin/bash

## 环境变量
source /op-tools/env
MONGO_ADDR_R=${MONGO_ADDR:-localhost}
MONGO_PORT_R=${MONGO_PORT:-27017}
MONGO_USER_R=${MONGO_USER:-root}
MONGO_PW_R=${MONGO_PW:-root}
MONGO_DB_R=${MONGO_DB:=_ALL_}
MONGO_AUTHDB_R=${MONGO_AUTHDB:=admin}
MONGO_BK_RETAIN_R=${BK_RETAIN:-14}


## 备份 MongoDB 数据库
date_tag=$(date +%Y%m%d-%H%M)
if [[ $MONGO_DB_R == "_ALL_" ]];then
    mkdir -p /mnt/mongo__all__${date_tag}
    mongodump -h ${MONGO_ADDR_R} --port ${MONGO_PORT_R} -u ${MONGO_USER_R} -p=${MONGO_PW_R} --authenticationDatabase ${MONGO_AUTHDB_R} -o /mnt/mongo__all__${date_tag}
else
    mkdir -p /mnt/mongo_${MONGO_DB_R}_${date_tag}
    mongodump -h ${MONGO_ADDR_R} --port ${MONGO_PORT_R} -u ${MONGO_USER_R} -p=${MONGO_PW_R} -d ${MONGO_DB_R} --authenticationDatabase ${MONGO_AUTHDB_R} -o /mnt/mongo_${MONGO_DB_R}_${date_tag}
fi

## 打包压缩
cd /mnt
ls -d -1 mongo_* | grep -v .zip | xargs -I {} zip -r {}.zip {}
ls -d -1 mongo_* | grep -v .zip | xargs -I {} rm -fr {}

## 清理过时的备份数据
cd /mnt
if [[ $MONGO_DB_R == "_ALL_" ]];then
    bk_num=$(ls -Art mongo__all__*.zip | wc -l)
else
    bk_num=$(ls -Art mongo_${MONGO_DB_R}_*.zip | wc -l)
fi
if [[ $bk_num -gt ${MONGO_BK_RETAIN_R} ]];then
    if [[ $MONGO_DB_R == "_ALL_" ]];then
        find /mnt/ -name "mongo__all__*.zip" | sort -r | sed -e 1,${MONGO_BK_RETAIN_R}d | xargs -I {} rm -f {}
    else
        find /mnt/ -name "mongo_${MONGO_DB_R}_*.zip" | sort -r | sed -e 1,${MONGO_BK_RETAIN_R}d | xargs -I {} rm -f {}
    fi
fi




