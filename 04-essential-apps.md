# 第四步：必装 Docker 应用推荐 (Productivity Tools)

> **目标**：部署生产力工具，并配置自动化运维容器。
> **前置**：Docker 环境已就绪（参考第三步）。

---

## 🛠️ 1. 部署你的核心工具

这些是我们编译好的、针对 ARM64 优化的生产力工具。

### 1.1 图片水印工具 (Watermark Tool)
基于 Nuxt 的本地水印处理工具，安全隐私，无云端上传。

```bash
# 启动命令
# 映射端口: 宿主机 3001 -> 容器 3000
docker run -d \
  --name watermark \
  --restart always \
  -p 3001:3000 \
  --memory="256m" \
  sr2006/image-watermark-tool:latest
  ```

- **访问**: `http://192.168.1.200:3001` (或网关 IP `192.168.2.1:3001`)
    

### 1.2 PicSeal (隐形水印)

基于 Rust + WebAssembly 的高性能隐形水印工具，极其轻量。

Bash

```
# 启动命令
# 映射端口: 宿主机 8082 -> 容器 80
docker run -d \
  --name picseal \
  --restart always \
  -p 8082:80 \
  --memory="128m" \
  sr2006/picseal:arm64
```

- **访问**: `http://192.168.1.200:8082`
    

---

## 🗼 2. 部署 Watchtower (自动更新)

**为什么要装它？** 你不想每次更新了代码推送到 Docker Hub 后，还要 SSH 连到板子上手动拉取镜像吧？Watchtower 会每隔 24 小时检查一次，如果有新镜像，它会自动拉取并优雅重启容器。

Bash

```
docker run -d \
    --name watchtower \
    --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup \
    --schedule "0 0 4 * * *"
```

- **配置说明**:
    
    - `--cleanup`: 更新后自动删除旧镜像，防止 SD 卡爆满。
        
    - `--schedule`: 这里设置的是每天凌晨 4 点检查更新（避开使用高峰）。
        

---

## 📊 3. 极简容器管理 (Dockge)

_如果不想用命令行管理 Docker，Portainer 对 1GB 内存来说太重了，推荐用 **Dockge**。_

Bash

```
# 创建数据目录
mkdir -p /opt/dockge
cd /opt/dockge

# 下载 Compose 文件 (Dockge 推荐用 Compose 管理)
curl [https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml](https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml) --output compose.yaml

# 启动
docker compose up -d
```

- **访问**: `http://192.168.1.200:5001`
    
- **特点**: 界面极其清爽，内存占用极低，能把你的 `docker run` 命令自动转成 `docker-compose.yml` 管理。