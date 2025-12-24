# Orange Pi Zero 3 全能微型服务器实战指南 (All-in-One Guide)

[![Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://www.docker.com/)
[![Arch](https://img.shields.io/badge/Arch-ARM64-orange.svg)]()
[![Status](https://img.shields.io/badge/Status-Production%20Ready-green.svg)]()

> 把仅有 1GB 内存的 Orange Pi Zero 3 榨干到极致：透明网桥 + Docker 构建站 + 私有云。

## 📖 简介 (Introduction)

本项目记录了如何在 Orange Pi Zero 3 (H618, 1GB RAM) 上，克服内核阉割、内存不足、网络受限等困难，打造一个极其稳定的微型服务器。

**核心特性：**
* **透明网桥**：将 WiFi 信号无损转换为有线信号（给电视/电脑供网），支持混杂模式。
* **软件工厂**：在 ARM64 架构上直接编译构建 Rust、Node.js、Deno 等现代应用。
* **系统防爆**：针对无 ZRAM 环境的 Swap 调优与内核锁定策略。

---

## 🚀 快速开始 (Quick Start)

### 1. 基础环境
* **硬件**：Orange Pi Zero 3 (1GB/1.5GB) + 32GB 高速 SD 卡 (A1/A2级)。
* **系统**：Armbian / Debian (Legacy Kernel 6.1.x 或类似)。
* **前置条件**：配置好静态 IP，更换国内 apt 源。

### 2. 系统加固 (System Hardening)
由于部分固件阉割了 ZRAM 模块，必须配置 Swap 并调整调度策略以防止 OOM 死机。

```bash
# 1. 创建 2GB Swap 并开机挂载
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 2. 调整 Swappiness (仅在内存剩余 10% 时才使用 Swap，防止卡顿)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. 锁定内核 (至关重要！防止自动更新搞挂 WiFi 驱动)
sudo apt-mark hold linux-image-current-sun50iw9
sudo apt-mark hold linux-dtb-current-sun50iw9
````

### 3. Docker 构建加速 (Build Protocol)

在 ARM 板上编译软件，网络是最大瓶颈。请参考 `docker-templates/` 目录下的 Dockerfile 最佳实践。

**Node.js 项目示例：**

Dockerfile

```
FROM node:18-alpine
# 关键：设置 npmmirror 加速依赖下载
RUN npm config set registry [https://registry.npmmirror.com](https://registry.npmmirror.com)
COPY . .
RUN npm install && npm run build
```

**Rust 项目示例：**

Dockerfile

```
FROM rust:alpine
# 关键：设置 USTC 镜像源
ENV RUSTUP_DIST_SERVER=[https://mirrors.ustc.edu.cn/rust-static](https://mirrors.ustc.edu.cn/rust-static)
# ...后续构建步骤
```

---

## 🛠️ 网络配置 (Networking)

_详情请见 `network/` 目录_

本方案使用 `parprouted` 实现 Layer 3 透明代理 ARP 桥接。

1. 安装依赖：`sudo apt install parprouted dhcp-helper brouter`
    
2. 开启内核转发：`net.ipv4.ip_forward=1`
    
3. 配置逻辑：让 `eth0` (有线) 借用 `wlan0` (无线) 的路由表。
    

---

## ⚠️ 运维十诫 (The Ten Commandments)

1. **绝对禁止** 运行 `apt dist-upgrade`（会升级内核导致网桥失效）。
    
2. Docker 容器建议添加内存限制 (e.g., `--memory="256m"`).
    
3. 重大变更前，请使用 Win32DiskImager 进行全盘冷备份。
    
4. **散热是刚需**：H618 发热量大，必须加装散热片或散热壳。
    
5. **If it works, don't touch it.** (能跑就别动)。
    

---

## 🤝 贡献

欢迎提交 Issue 或 PR 分享你在 Orange Pi 上的折腾经验。