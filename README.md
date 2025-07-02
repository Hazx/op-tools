# OP-TOOLS

这是一个用来辅助运维的工具镜像，你可以用它来备份数据库，也可以作为 SSH 跳板。

- 支持 X86/ARM64 平台
- 支持 SSH Server/Client
- 支持 Crontab 定时任务
- 支持 MySQL 数据库操作及自动备份任务
- 支持 MongoDB 数据库操作及自动备份任务


## 组件信息

- 基础镜像：Ubuntu 22.04 (Jammy)
- APT 源：北京外国语大学开源软件镜像站
- 默认 ROOT 密码：wpuU2gurjYFLyBq
- 默认时区：Asia/Shanghai
- MySQL 工具版本：8.0.42
- Mongo 工具版本：6.0.24


## 可配置变量

- `SET_PWD`：配置 root 密码
- `RUN_SSH`：启用 SSH（`true` / `false`，默认 `false`）
- `RUN_CROND`：启用定时任务（`true` / `false`，默认 `false`）
- `RUN_KEEP`：保持容器不退出（`true` / `false`，默认 `false`）
- `MYSQL_ADDR`：MySQL 地址
- `MYSQL_PORT`：MySQL 端口（默认 `3306`）
- `MYSQL_USER`：MySQL 认证用户（默认 `root`）
- `MYSQL_PW`：MySQL 认证密码（若含 `$` 和 `"` 请在字符前增加 `\`）
- `MYSQL_DB`：MySQL 库名（填 `_ALL_` 则为所有库）
- `MONGO_ADDR`：MongoDB 地址
- `MONGO_PORT`：MongoDB 端口（默认 `27017`）
- `MONGO_USER`：MongoDB 认证用户（默认 `root`）
- `MONGO_PW`：MongoDB 认证密码（若含 `$` 和 `"` 请在字符前增加 `\`）
- `MONGO_DB`：MongoDB 库名（填 `_ALL_` 则为所有库）
- `MONGO_AUTHDB`：MongoDB 认证库名（默认 `admin`）
- `BK_RETAIN`：备份保留个数（默认 `14`）
- `BK_DIR`：备份目录（默认 `/mnt`）
- `BK_CROND_MODE`：备份计划任务类型（`mysql` / `mongo`）
- `BK_CROND_TIME`：备份计划任务定时配置（同 crontab 的时间部分写法）


## 可映射端口

- `22`：SSH Server


## 可映射路径

- `/op-tools/crontab-list`：crontab 定时任务配置
- `/mnt`：备份任务存储目录 


## 功能详解
### SSH

用于调试或作为 SSH 跳板机。

开启 SSH 功能需配置变量 `RUN_SSH=true`，可以通过变量 `SET_PWD=xxx` 来配置 root 密码，另外还需要映射 22 端口。开启 SSH 功能后，容器会保持运行不自动退出。


### 定时任务

Linux Crontab 定时任务。

开启定时任务功能需配置变量 `RUN_CROND=true`，另外还需要映射配置文件到 `/op-tools/crontab-list`，配置文件参考：[crontab-list](build/crontab-list)。开启定时任务功能后，容器会保持运行不自动退出。


### MySQL 数据库备份

用于定时备份 MySQL 数据库。

开启 MySQL 数据库备份需配置 `MYSQL_` 开头的几个变量，并配置变量 `BK_RETAIN`。若需要开启定时自动备份，还需要配置 `RUN_CROND=true`、`BK_CROND_MODE=mysql`、`BK_CROND_TIME`，`BK_CROND_TIME` 写法同 crontab 的时间部分，例如 `BK_CROND_TIME="0 2 * * *"`。

存储方面，需要映射容器中目录 `/mnt`，备份数据将保存至此，此目录中请勿出现其他数据避免被误删。

如需立即备份数据库，可在创建容器时增加运行命令 `/op-tools/start.sh bkmysql`。若只是创建定时任务，则不加运行命令。


### MongoDB 数据库备份

用于定时备份 MongoDB 数据库。暂仅支持 password 认证方式。

开启 MongoDB 数据库备份需配置 `MONGO_` 开头的几个变量，并配置变量 `BK_RETAIN`。若需要开启定时自动备份，还需要配置 `RUN_CROND=true`、`BK_CROND_MODE=mongo` 和 `BK_CROND_TIME`，`BK_CROND_TIME` 写法同 crontab 的时间部分，例如 `BK_CROND_TIME="0 2 * * *"`。

存储方面，需要映射容器中目录 `/mnt`，备份数据将保存至此，此目录中请勿出现其他数据避免被误删。

如需立即备份数据库，可在创建容器时增加运行命令 `/op-tools/start.sh bkmongo`。若只是创建定时任务，则不加运行命令。



## 打包镜像

您可以直接使用已经打包好的镜像 `hazx/optools:2.3`（ARM64平台请使用镜像 `hazx/optools:2.3-arm`），若您有特殊需求也可在修改之后重新执行打包：

```
bash build.sh
```

## 在 Kubernetes 中使用 OP-TOOLS

若您需要在 Kubernetes 中使用 OP-TOOLS，可以参考 [k8s.yaml](k8s.yaml) 进行。