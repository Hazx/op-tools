#!/bin/bash

tag=1.1

rm -f Dockerfile
sudo tee -a Dockerfile << EOF
FROM centos:7.9.2009

LABEL maintainer=hazx@vip.qq.com
LABEL Version=${tag}

COPY init_files /op-tools

RUN chmod +x /op-tools/IDR-build-sh ;\
    bash /op-tools/IDR-build-sh ;\
    rm -f /op-tools/IDR-build-sh

CMD /op-tools/start.sh
EOF

docker build -t optools:${tag} .
docker save optools:${tag} | gzip -c > optools-${tag}.tar.gz