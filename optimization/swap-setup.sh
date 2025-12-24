#!/bin/bash
# Orange Pi Zero 3 内存救援脚本
# 功能: 创建 2GB Swap + 优化 Swappiness 防止卡顿
# 运行方式: sudo bash swap-setup.sh

echo ">>> 开始创建 2GB Swap 文件..."
# 1. 创建 2GB 空文件 (速度快)
sudo fallocate -l 2G /swapfile
# 2. 设置权限 (只有 root 能读写，安全要求)
sudo chmod 600 /swapfile
# 3. 格式化为 Swap
sudo mkswap /swapfile
# 4. 启用 Swap
sudo swapon /swapfile

echo ">>> 设置开机自启..."
# 写入 fstab，防止重启失效
# 使用 grep 检查是否已经存在，避免重复写入
if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Fstab 更新成功。"
else
    echo "Fstab 已存在配置，跳过。"
fi

echo ">>> 优化内存调度策略 (Swappiness)..."
# 将 swappiness 设为 10 (默认是 60)
# 意思是：物理内存只剩 10% 时才用 Swap，防止日常操作卡顿
sudo sysctl vm.swappiness=10
# 永久写入配置文件
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    echo "Sysctl 配置更新成功。"
else
    echo "Sysctl 已配置，跳过。"
fi

echo ">>> 验证结果："
free -h
echo ">>> 完成！你的系统现在有防死机保险了。"