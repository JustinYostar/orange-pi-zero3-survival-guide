# 🍊 Orange Pi Zero 3 Survival Guide (全能微型服务器生存指南)

![Platform](https://img.shields.io/badge/Platform-ARM64%20%7C%20H618-orange?style=flat-square)
![System](https://img.shields.io/badge/System-Armbian%20%2F%20Debian-blue?style=flat-square&logo=debian)
![Docker](https://img.shields.io/badge/Docker-Production%20Ready-2496ED?style=flat-square&logo=docker)
![Status](https://img.shields.io/badge/Status-Stable-green?style=flat-square)

> **榨干 1GB 内存的极致性能：NAT 网关 + 科学网络 + Docker 编译站 + 私有云方案。**
> *A step-by-step guide to turning the Orange Pi Zero 3 into a robust micro-server.*

---

## 📖 项目简介 (Introduction)

本项目记录了如何在 **Orange Pi Zero 3 (Allwinner H618, 1GB RAM)** 上，克服内核阉割、内存不足、网络受限等困难，打造一个极其稳定的微型服务器与透明网关。

**核心成果：**
* **网络中枢**：作为 NAT 二级路由，提供 DHCP、DNS 缓存与透明代理（ShellCrash）。
* **全屋净网**：集成 AdGuard Home，实现全屋设备去广告与隐私保护。
* **生产力工具**：部署自研的图片水印工具与 PicSeal 隐私印章。
* **系统防爆**：针对无 ZRAM 环境的 Swap 调优与内核锁定策略。

---

## 🗺️ 实战路线图 (Roadmap)

**请按照以下顺序进行配置，不要跳步：**

### [第一步：基础准备与初始化](./01-initial-setup.md)
* **内容**：硬件避坑（电源/散热）、系统烧录、换源、SSH 连接。
* **目标**：让板子成功联网并处于一个干净、高速的初始状态。

### [第二步：NAT 网关与网络魔法](./02-nat-network-proxy.md)
* **内容**：配置 NAT 转发、dnsmasq DHCP 服务、部署 ShellCrash。
* **目标**：把 Pi 变成一个透明网关，下游设备插线即用，自动科学上网。

### [第三步：Docker 环境与 AdGuard Home](./03-adguard-home.md)
* **内容**：安装 Docker、配置国内加速镜像、解决 53 端口冲突、部署 AdGuard Home。
* **目标**：搭建容器基础环境，并接管 DNS 实现去广告。

### [第四步：必装应用推荐](./04-essential-apps.md)
* **内容**：部署水印工具、PicSeal、Dockge 管理面板、Watchtower 自动更新。
* **目标**：让服务器具备生产力功能。

### [第五步：系统清理与终极维护](./05-final-maintenance.md)
* **内容**：限制日志大小、Docker 垃圾清理策略、全盘冷备份指南。
* **目标**：防止 SD 卡爆满，确保持续稳定运行。

---

## 📂 资源目录 (Resources)

除了上述文档，本项目还包含以下脚本与模板供高级用户使用：

```text
.
├── network/                 # 🌐 网络配置备份
│   ├── bridge-setup.sh      # (备用) 透明网桥启动脚本
│   └── interfaces.example   # 网络接口配置参考
├── optimization/            # ⚡ 系统优化脚本
│   ├── swap-setup.sh        # 一键配置 2GB Swap + Swappiness
│   └── kernel-lock.sh       # 内核锁定脚本 (防变砖)
├── docker-templates/        # 🐳 Docker 构建模板 (CN Special)
│   ├── nodejs/              # 内置 npmmirror 源
│   ├── rust/                # 内置 USTC 源
│   └── deno/                # Deno 环境
└── maintenance/             # 🛡️ 维护脚本
    └── backup-guide.md      # 备份操作手册
    
```

---
## ⚠️ 运维十诫 (The Ten Commandments)

1. **绝对禁止** 运行 `apt dist-upgrade`（内核更新必挂 WiFi 驱动）。
    
2. **谨慎** 使用 `apt upgrade`，建议只单独更新需要的软件包。
    
3. **注意网卡名称**：配置网络时，务必检查是 `eth0` 还是 `end0`。
    
4. Docker 容器建议限制内存，例如 `--memory="256m"`。
    
5. 重大变更前，请使用 **Win32DiskImager** 进行全盘冷备份。
    
6. **散热是刚需**：H618 发热量大，必须加装散热片。
    
7. 没有 USB 3.0 U盘做 Swap 的话，请务必买一张 A1/A2 级的高速 SD 卡。
    
8. 能用 Docker 跑的服务，绝不直接装在宿主机上（ShellCrash 除外）。
    
9. 定期清理 Docker 垃圾：`docker system prune`。
    
10. **If it works, don't touch it.** (能跑就别动)。
    

---

## 🤝 贡献 (Contributing)

欢迎提交 PR 分享你在 Orange Pi 上的折腾经验！

## 📄 许可证 (License)

MIT License