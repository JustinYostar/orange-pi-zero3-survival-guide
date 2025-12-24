# 第三步：Docker 环境搭建与 AdGuard Home 部署

> **目标**：
> 1. 安装 Docker 容器引擎并配置国内加速源。
> 2. 部署 AdGuard Home，接管局域网 DNS，实现去广告和 DNS 缓存加速。

---

## 🐳 1. 安装 Docker 环境 (基础建设)

在部署任何应用之前，我们需要先给 Orange Pi 装上 Docker 引擎。

### 1.1 一键安装脚本
Armbian/Debian 系统使用官方脚本安装最方便。为了提高速度，我们指定使用阿里云镜像。

```bash
# 下载并运行安装脚本 (使用阿里云镜像源)
curl -fsSL [https://get.docker.com](https://get.docker.com) | bash -s docker --mirror Aliyun
```
### 1.2 设置用户权限

安装完成后，默认只有 root 能运行 docker。为了方便后续操作（避免每次都输 sudo），把当前用户加入 docker 组。

Bash

```
# 将当前用户加入 docker 组
sudo usermod -aG docker $USER

# 刷新组权限 (或者重启板子)
newgrp docker

# 验证是否安装成功 (能看到 Client 和 Server 信息即成功)
docker version
```

### 1.3 配置国内镜像加速 (必做!)

由于 Docker Hub 在国内访问困难，必须配置镜像加速器，否则后续拉取 AdGuard 镜像会超时失败。

Bash

```
# 1. 创建配置目录
sudo mkdir -p /etc/docker

# 2. 写入镜像源配置 (这里使用了几个常用的国内源)
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "[https://docker.m.daocloud.io](https://docker.m.daocloud.io)",
    "[https://huecker.io](https://huecker.io)",
    "[https://dockerhub.timeweb.cloud](https://dockerhub.timeweb.cloud)",
    "[https://noohub.ru](https://noohub.ru)"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# 3. 重启 Docker 服务让配置生效
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 🛑 2. 清理 53 端口 (为 AGH 腾地盘)

AdGuard Home (AGH) 必须运行在 `53` 端口才能生效。但 Linux 系统自带的 `systemd-resolved` 和我们刚才配置的 `dnsmasq` 可能正占着这个坑。

### 2.1 停用 systemd-resolved

这是 Ubuntu/Debian 默认的 DNS 服务，必须关掉。

Bash

```
# 停止并禁用服务
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# 删除软链接，防止 DNS 解析锁死
sudo rm /etc/resolv.conf

# 创建临时 DNS，防止板子断网
echo "nameserver 223.5.5.5" | sudo tee /etc/resolv.conf
```

### 2.2 修改 dnsmasq 配置

如果你在 **第二步 (NAT)** 中启用了 dnsmasq，它现在正占着 53 端口。我们需要保留它的 DHCP 功能，但关掉它的 DNS 功能。

编辑配置：`sudo nano /etc/dnsmasq.conf`

**修改以下关键项**：

Ini, TOML

```
# --- 核心修改 ---
# port=0 表示禁用 dnsmasq 的 DNS 功能，只做 DHCP
port=0

# --- DNS 下发 ---
# 告诉下游设备：DNS 还是找网关(192.168.2.1)，但接电话的将是 AdGuard
dhcp-option=6,192.168.2.1
```

重启 dnsmasq：

Bash

```
sudo systemctl restart dnsmasq
```

---

## 🛡️ 3. 部署 AdGuard Home

现在环境好了，路也通了，开始部署 AGH。

### 3.1 创建数据目录

为了防止删除容器后数据丢失，我们需要把配置文件挂载到宿主机。

Bash

```
mkdir -p /home/root/adguard/work
mkdir -p /home/root/adguard/conf
```

### 3.2 启动容器 (Host 模式)

我们使用 `host` 网络模式，这样 AGH 能看到真实的客户端 IP（而不是 Docker 网关 IP），方便管理。

Bash

```
docker run -d \
    --name adguardhome \
    --restart always \
    --network host \
    -v /home/root/adguard/work:/opt/adguardhome/work \
    -v /home/root/adguard/conf:/opt/adguardhome/conf \
    adguard/adguardhome
```

---

## ⚙️ 4. 初始化配置 (Web 界面)

1. **打开浏览器**：访问 `http://192.168.1.200:3000` (或你的网关 IP)。
    
2. **开始配置**：
    
    - **网页管理端口**：建议改为 `3000` 或 `8080` (只要不冲突)。
        
    - **DNS 服务器端口**：**必须保留为 53**。
        
    - _如果此处提示 53 被占用，请回头检查第 2 步。_
        
3. **设置上游 DNS**：
    
    - 进入 **设置 -> DNS 设置**。
        
    - 上游 DNS 服务器：如果你部署了 ShellCrash (TProxy)，建议填写 `127.0.0.1:1053` (让流量走代理)。
        
    - 如果没部署 ShellCrash，填写 `223.5.5.5` 和 `119.29.29.29`。
        

---

**🎉 这一步完成后，你拥有了：**

1. 一个配置好国内源的 **Docker 平台**（可以随意安装其他软件了）。
    
2. 一个全功能的 **AdGuard Home**（全屋去广告）。