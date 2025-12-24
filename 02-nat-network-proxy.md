# 第二步：NAT 网关配置与 ShellCrash 部署

> **⚠️ 核心警告**：
> 在开始之前，请务必确认你的网卡名称！
> 不同的系统版本（Armbian vs 官方镜像），有线网卡可能叫 `eth0`，也可能叫 `end0`。
> **请将下文中的 `eth0` 替换为你实际的网卡名称。**

---

## 🛠️ 1. 配置 NAT 路由模式

### 1.1 检查网卡名称 (必做)
在终端输入：
```bash
ip link show
```
- 观察输出，找到代表有线网口的那个名字（通常是 `eth0` 或 `end0`）。
    
- 找到代表无线网口的那个名字（通常是 `wlan0`）。
    
- **下文配置中，凡是出现 `eth0` 的地方，请根据你的实际情况修改！**

### 1.2 安装基础软件

我们需要 `dnsmasq` (DHCP/DNS服务器) 和 `iptables` (防火墙/NAT转发)。

Bash

```
sudo apt update
sudo apt install dnsmasq iptables-persistent curl
```

### 1.3 固定有线接口 IP (作为网关)

编辑网络配置：`sudo nano /etc/network/interfaces`

Plaintext

```
# ETH0 (或 end0) - 下游局域网网关
allow-hotplug eth0
iface eth0 inet static
    address 192.168.2.1      # Pi 的内网 IP
    netmask 255.255.255.0
```

### 1.4 配置 DHCP Server (dnsmasq)

备份原配置：`sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak` 新建配置：`sudo nano /etc/dnsmasq.conf`

写入核心配置（**注意替换 interface=后面的名字**）：

Ini, TOML

```
# --- 监听配置 ---
# 注意：如果是 end0 请改为 interface=end0
interface=eth0
bind-interfaces

# --- 地址池配置 ---
dhcp-range=192.168.2.50,192.168.2.150,255.255.255.0,12h

# --- 关键下发参数 ---
dhcp-option=3,192.168.2.1
dhcp-option=6,192.168.2.1
dhcp-option=option:router,192.168.2.1
```

重启服务：

Bash

```
sudo systemctl restart dnsmasq
```

### 1.5 开启 NAT 转发

1. **开启内核转发**： 编辑 `/etc/sysctl.conf`，确保 `net.ipv4.ip_forward=1`。 执行 `sudo sysctl -p` 生效。
    
2. **设置防火墙规则 (iptables)**：
    
    Bash
    
    ```
    # 开启伪装 (Masquerade)
    # 注意：如果你的有线网卡是 end0，请修改相关参数，但 NAT 主要涉及出口 wlan0
    sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    
    # 允许转发 (注意替换 eth0)
    sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
    sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # 永久保存
    sudo netfilter-persistent save
    ```

---

## 🚀 2. 部署 ShellCrash (科学上网)

ShellCrash 是一个极其轻量、专为软路由设计的 Clash 管理脚本，直接运行在 Linux 内核之上，效率极高。

### 2.1 一键安装

在 SSH 终端执行官方/社区安装脚本（需确保板子此时能联网）：

Bash

```
# 推荐使用 GitHub 源 (如果连不上，请搜索国内镜像源)
export url='[https://fastly.jsdelivr.net/gh/juewuy/ShellCrash@master](https://fastly.jsdelivr.net/gh/juewuy/ShellCrash@master)' && sh -c "$(curl -kfsSl $url/install.sh)" && source /etc/profile &> /dev/null
```

### 2.2 初始配置 (交互式)

安装完成后，输入 `crash` 即可进入管理菜单。

**推荐配置步骤**：

1. **选择内核**：推荐选择 **Meta 内核 (Mihomo)**，支持协议最全。
    
2. **导入订阅**：输入你的订阅链接。
    
3. **模式设置**：
    
    - 选择 **TProxy 模式** (透明代理最推荐的模式，支持 UDP 转发)。
        
    - 或者 **Tun 模式** (通用性最好)。
        
4. **局域网转发**：
    
    - 确保开启 **“允许局域网连接”**。
        
    - 确保开启 **“本机代理”** (让 Pi 自己拉镜像也能走代理)。
        
5. **DNS 设置**：
    
    - ShellCrash 通常会劫持 DNS (默认端口 1053)。
        
    - **重要**：因为我们在 1.3 步里把 DHCP 的 DNS 指向了 Pi 自己 (192.168.2.1)，所以流量到达 Pi 后，会被 ShellCrash 的 DNS 模块接管，实现国内外域名分流。
        

### 2.3 验证

配置完成后，将你的电脑用网线连接到 Pi 的网口。

- 电脑应该会自动获取到 `192.168.2.x` 的 IP。
    
- 打开浏览器访问 Google，如果能通，说明透明网关搭建成功！
    

---

## 🖨️ 3. 局域网打印机发现 (Avahi)

_由于 NAT 隔离了网段，如果你需要让子网设备发现主网打印机，请配置此项。_

Bash

```
# 安装
sudo apt install avahi-daemon

# 编辑配置 /etc/avahi/avahi-daemon.conf
# 修改 [reflector] 字段:
# enable-reflector=yes

# 重启
sudo systemctl restart avahi-daemon
```
