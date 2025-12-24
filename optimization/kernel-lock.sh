#!/bin/bash
# 内核版本锁定脚本
# 作用: 禁止 apt upgrade 更新内核，防止 WiFi 驱动失效
# 运行方式: sudo bash kernel-lock.sh

echo ">>> 正在锁定内核相关包..."

# 针对 Orange Pi 官方/Armbian 常见的内核包名
# 使用 apt-mark hold 命令将它们标记为"保留"
sudo apt-mark hold linux-image-current-sun50iw9
sudo apt-mark hold linux-dtb-current-sun50iw9
sudo apt-mark hold armbian-firmware

echo ">>> 当前锁定状态："
# 显示所有被锁定的包
dpkg --get-selections | grep hold

echo ">>> 锁定完成！现在运行 apt upgrade 是安全的。"
echo "注意：绝对禁止运行 apt dist-upgrade！"