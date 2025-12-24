#!/bin/bash
# Orange Pi Zero 3 透明网桥启动脚本
# 适用系统: Armbian / Debian
# 依赖软件: sudo apt install parprouted dhcp-helper
# 放置位置: 建议放在 /usr/local/bin/bridge-setup.sh 并设置开机自启

# 0. 清理可能存在的旧进程 (防止重复启动)
killall parprouted dhcp-helper 2>/dev/null

# 1. 启用内核 IP 转发功能 (核心)
echo 1 > /proc/sys/net/ipv4/ip_forward

# 2. 激活有线接口 (但不分配 IP)
ip link set eth0 up
ip addr flush dev eth0

# 3. 启动 parprouted (ARP 代理桥接)
# 作用：把 wlan0 (无线) 和 eth0 (有线) 桥接起来，让它们看起来像同一个网段
parprouted eth0 wlan0

# 4. 启动 dhcp-helper (DHCP 中继)
# 作用：让插在网口的设备，能穿透板子，直接向家里的主路由申请 IP
# -b wlan0: 指定广播接口为无线口
dhcp-helper -b wlan0