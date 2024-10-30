#!/bin/bash

docker_path=hazx
docker_img=optools
docker_tag=2.2
docker_base=ubuntu:jammy-20240911.1
web_svc_img=hazx/hmengine-fe:1.7

arch=$(uname -p)
if [[ $arch == "aarch64" ]] || [[ $arch == "arm64" ]];then
    docker_tag=${docker_tag}-arm
    web_svc_img=${web_svc_img}-arm
fi

## 代理
# if [ $http_proxy ];then
#     echo "export http_proxy=${http_proxy}" >> IDR-env
# fi
# if [ $https_proxy ];then
#     echo "export https_proxy=${https_proxy}" >> IDR-env
# fi
# if [ $no_proxy ];then
#     echo "export no_proxy=\"${no_proxy}\"" >> IDR-env
# fi

## 启动临时web服务
# pwd_dir=$(cd $(dirname $0); pwd)
# docker run -d --name tmp-build-web \
#     -v ${pwd_dir}/res:/web_server/html \
#     -e FE_PORT=8000 \
#     --hostname tmp-build-web \
#     ${web_svc_img}
# sleep 3
# web_ip=$(docker exec tmp-build-web bash -c "cat /etc/hosts | grep tmp-build-web" | awk '{print $1}')
# echo "export RES_WEB=${web_ip}:8000" >> IDR-env

rm -f Dockerfile
cat <<EOF > Dockerfile
FROM ${docker_base}
COPY IDR-bk-mongo-sh /op-tools/bk_mongo.sh
COPY IDR-bk-mysql-sh /op-tools/bk_mysql.sh
COPY IDR-build-sh /op-tools/build.sh
COPY IDR-start-sh /op-tools/start.sh
COPY IDR-env /op-tools/env
COPY crontab-list /op-tools/crontab-list
RUN chmod +x /op-tools/*.sh ;\
    . /op-tools/env ;\
    /op-tools/build.sh ;\
    rm -f /op-tools/build.sh
WORKDIR /op-tools
CMD /op-tools/start.sh
EOF

docker build --progress=plain -t ${docker_path}/${docker_img}:${docker_tag} .
docker save ${docker_path}/${docker_img}:${docker_tag} | gzip -c > ${docker_img}-${docker_tag}.tar.gz
docker rmi ${docker_path}/${docker_img}:${docker_tag}
# docker rm -f tmp-build-web
# docker rmi ${web_svc_img}
rm -f Dockerfile