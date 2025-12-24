# 🍊 Orange Pi Zero 3 Survival Guide (全能微型服务器生存指南)

![Platform](https://img.shields.io/badge/Platform-ARM64%20%7C%20H618-orange?style=flat-square)
![System](https://img.shields.io/badge/System-Armbian%20%2F%20Debian-blue?style=flat-square&logo=debian)
![Docker](https://img.shields.io/badge/Docker-Production%20Ready-2496ED?style=flat-square&logo=docker)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> **榨干 1GB 内存的极致性能：透明网桥 + Docker 编译站 + 私有云方案。**
> *Turning the Orange Pi Zero 3 into a robust micro-server and transparent bridge.*

---

## 📖 项目简介 (Introduction)

本项目是针对 **Orange Pi Zero 3 (Allwinner H618, 1GB RAM)** 的全套调优与运维指南。

旨在解决以下核心痛点：
1.  **内核阉割**：官方/社区固件常缺失 ZRAM 等模块，导致系统易死机。
2.  **网络受限**：ARM 架构下 Node.js/Rust 依赖下载缓慢，构建失败。
3.  **单网口限制**：如何利用 WiFi 接口实现 Layer 3 透明网桥，为其他设备供网。
4.  **维护风险**：`apt upgrade` 意外更新内核导致 WiFi 驱动失效。

---

## 📂 目录结构 (Directory Structure)

```text
.
├── network/                 # 🌐 网络魔改模块
│   ├── bridge-setup.sh      # 透明网桥启动脚本 (parprouted + dhcp-helper)
│   └── interfaces.example   # /etc/network/interfaces 配置模板
├── optimization/            # ⚡ 系统内核调优模块
│   ├── swap-setup.sh        # 一键配置 2GB Swap + Swappiness 优化
│   └── kernel-lock.sh       # 锁定内核版本，防止驱动失效
├── docker-templates/        # 🐳 Docker 构建加速模板 (CN Special)
│   ├── nodejs/              # 内置 npmmirror 源
│   ├── rust/                # 内置 USTC 源 + Cargo 配置
│   └── deno/                # 轻量级 Deno 运行环境
└── maintenance/             # 🛡️ 运维与灾备
    └── backup-guide.md      # 系统全盘冷备份与恢复指南
```
## 🚀 核心功能 (Features)

### 1. 透明网桥 (Transparent Bridge)

利用 `parprouted` 实现 ARP 代理，让 WLAN0 (无线) 和 ETH0 (有线) 处于同一网段。

- **场景**：电视/电脑通过网线连接 Pi，Pi 通过 WiFi 上网。
    
- **优势**：无需 NAT，支持从主路由直接管理子设备。
    

### 2. Docker 编译加速工厂 (Build Factory)

专为中国大陆网络环境优化的 `Dockerfile` 模板，解决 ARM64 架构下编译超时的痛点。

- **Rust**: 集成 USTC 镜像源，解决 `crates.io` 索引更新慢的问题。
    
- **Node.js**: 集成 `npmmirror`，秒级安装依赖。
    

### 3. 系统防爆机制 (System Hardening)

针对 1GB 小内存环境的生存策略：

- **智能 Swap**: 只有当物理内存剩余 <10% 时才使用 Swap，保护 SD 卡寿命并防止卡顿。
    
- **内核锁**: 自动化脚本锁定 `linux-image` 和 `linux-dtb`，防止自动更新导致“变砖”。
    

---

## 🛠️ 快速开始 (Quick Start)

### 第一步：系统初始化与防爆

下载仓库并运行优化脚本：

Bash

```
git clone [https://github.com/YourUsername/orange-pi-zero3-survival-guide.git](https://github.com/YourUsername/orange-pi-zero3-survival-guide.git)
cd orange-pi-zero3-survival-guide/optimization

# 1. 开启 Swap 并优化内存调度
sudo bash swap-setup.sh

# 2. 锁定内核 (至关重要!)
sudo bash kernel-lock.sh
```

### 第二步：配置透明网桥

请参考 `network/` 目录下的配置文件。

1. 将 `interfaces.example` 内容适配后写入 `/etc/network/interfaces`。
    
2. 设置 `bridge-setup.sh` 开机自启。
    

### 第三步：构建 Docker 镜像

进入 `docker-templates` 选择对应语言模板：

Bash

```
cd docker-templates/nodejs
# 使用 Host 网络模式以避免 DNS 问题
docker build --network=host -t my-node-app .
```

---

## ⚠️ 运维十诫 (The Ten Commandments)

1. **绝对禁止** 运行 `apt dist-upgrade`（内核更新必挂 WiFi）。
    
2. **谨慎** 使用 `apt upgrade`，建议只单独更新需要的软件包。
    
3. Docker 容器建议限制内存，例如 `--memory="256m"`。
    
4. 重大变更前，请使用 **Win32DiskImager** 进行全盘冷备份。
    
5. **散热是刚需**：H618 发热量大，必须加装散热片。
    
6. 没有 USB 3.0 U盘做 Swap 的话，请务必买一张 A1/A2 级的高速 SD 卡。
    

---

## 🤝 贡献 (Contributing)

欢迎提交 PR 分享你在 Orange Pi 上的折腾经验！

## 📄 许可证 (License)

MIT License
