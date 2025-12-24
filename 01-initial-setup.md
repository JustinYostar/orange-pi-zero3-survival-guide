# 第一步：准备工作与系统初始化 (Getting Started)

> **目标**：从零开始，完成硬件组装、系统烧录，并成功 SSH 连接到 Orange Pi Zero 3，做好基础环境配置。

## 🛒 1. 硬件准备 (必读避坑指南)

在动手之前，请确保你手头有以下东西。Orange Pi Zero 3 虽然便宜，但对周边配件很挑剔。

* **[核心] Orange Pi Zero 3 开发板**: 建议购买 1.5GB 或 2GB 内存版本（1GB 版本虽然也能用本项目优化，但宽裕点总是好的）。
* **[必选] 散热片/散热壳**: H618 芯片发热极其严重！**不加散热片必死机**。推荐铝合金全包外壳。
* **[必选] 供电电源**:
    * 必须是 **5V 3A** 的 Type-C 电源头。
    * ❌ **禁止使用** 电脑 USB 口供电（电流不够，会反复重启）。
    * ❌ **尽量避免** 使用超级快充头（协议握手可能失败），普通的 5V3A 最好。
* **[必选] MicroSD 卡**: 建议 **32GB** 起步，认准 **Class 10**、**A1** 或 **A2** 标识（如闪迪红灰卡、三星白卡）。劣质卡会让你跑 Docker 时卡顿。
* **[可选] 读卡器**: 用于在电脑上写系统。
* **[可选] Micro-HDMI 线**: 如果你第一次启动连不上网，接显示器是最后的排查手段。

## 💿 2. 软件下载

请在电脑上下载好以下工具：

1.  **烧录工具**: [BalenaEtcher](https://etcher.balena.io/) (傻瓜式，推荐) 或 Rufus。
2.  **SSH 终端**: [Putty](https://www.putty.org/) 或 [Termius](https://termius.com/) (界面好看，推荐)。
3.  **IP 扫描工具**: [Advanced IP Scanner](https://www.advanced-ip-scanner.com/cn/) (用来找板子的 IP 地址)。
4.  **系统镜像**:
    * 推荐下载 **Armbian** (社区维护版，稳定性好)。
    * 下载地址：[Armbian for Orange Pi Zero 3](https://www.armbian.com/orange-pi-zero-3/)
    * 版本选择：推荐 **Debian (Bookworm)** 或 **Ubuntu (Jammy)**。**注意：本项目基于 Debian 编写。**

## 🔥 3. 烧录系统

1.  把 SD 卡插入读卡器，插电脑。
2.  打开 **BalenaEtcher**。
3.  **Flash from file**: 选择你刚下载的 `.img.xz` 压缩包（不用解压）。
4.  **Select target**: 选择你的 SD 卡。
5.  **Flash!**: 点击开始，等待进度条走完。
6.  *完成后电脑可能会提示“需要格式化”，**点击取消**，直接拔出卡即可。*

## 🔌 4. 首次开机与连接

1.  **插卡**：将 SD 卡插入板子卡槽。
2.  **联网**：
    * **方案 A (推荐)**：用网线把板子连到路由器的 LAN 口。
    * **方案 B (无网线)**：此步骤较麻烦，建议先借根网线配置好 WiFi 再拔掉。
3.  **通电**：插上 Type-C 电源。
    * **观察指示灯**：红灯常亮（电源正常），绿灯闪烁（系统正在运行）。如果绿灯不亮，说明烧录失败或卡没插好。

4.  **寻找 IP 地址**：
    * 电脑上打开 **Advanced IP Scanner**，点击“扫描”。
    * 寻找主机名为 `orangepizero3` 或厂商为 `Shenzhen Xunlong` 的设备。
    * 记录下它的 IP 地址 (例如 `192.168.1.100`)。

5.  **SSH 登录**：
    * 打开 SSH 工具 (Putty/Termius)。
    * IP 填刚才查到的，端口 `22`。
    * 默认账号：`root`
    * 默认密码：`1234` (Armbian 默认) 或 `orangepi` (官方镜像默认)。
    * *首次登录会强制要求你修改密码，并创建一个普通用户（可以直接 Ctrl+C 跳过普通用户创建）。*

## ⚙️ 5. 基础环境配置 (换源与时区)

连上 SSH 后，依次执行以下命令，把环境调教成“中国友好模式”。

### 5.1 更换国内软件源 (清华源)
Armbian 默认源在国外，下载速度极慢。

```bash
# 1. 备份原配置
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 2. 自动替换为清华源 (适用于 Debian Bookworm)
sed -i 's|[http://deb.debian.org/debian](http://deb.debian.org/debian)|[https://mirrors.tuna.tsinghua.edu.cn/debian](https://mirrors.tuna.tsinghua.edu.cn/debian)|g' /etc/apt/sources.list
sed -i 's|[http://security.debian.org/debian-security](http://security.debian.org/debian-security)|[https://mirrors.tuna.tsinghua.edu.cn/debian-security](https://mirrors.tuna.tsinghua.edu.cn/debian-security)|g' /etc/apt/sources.list

# 3. 更新列表 (切记：此时不要执行 apt upgrade)
apt update
```
### 5.2 设置时区

Bash

```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone
date -R
# 此时应该显示 +0800
```

### 5.3 检查内核版本

Bash

```
uname -r
# 记录下这个版本号 (例如 6.1.31-sun50iw9)，后续我们可能会锁定它。
```

