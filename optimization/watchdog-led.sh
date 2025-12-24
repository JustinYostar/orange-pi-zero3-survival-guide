#!/bin/bash
# ---------------------------------------------------------
# Orange Pi Zero 3 生存套件：看门狗与红灯心跳
# 版本: V2.0 (Red LED + Anti-Kill Priority)
# ---------------------------------------------------------

echo ">>> [1/2] 配置 LED 灯语 (Red Heartbeat)..."

# 1. 自动寻找红灯路径
# Armbian 下通常叫 orangepi:red:pwr 或 orangepi:red:status
# 我们模糊匹配路径中包含 'red' 的文件夹
LED_PATH=$(find /sys/class/leds/ -name "*red*" | head -n 1)

if [ -n "$LED_PATH" ]; then
    echo "    找到红灯设备: $LED_PATH"
    
    # 设置为心跳模式
    echo "heartbeat" | sudo tee "$LED_PATH/trigger" > /dev/null
    
    # 写入 rc.local 确保重启生效
    if ! grep -q "heartbeat" /etc/rc.local; then
        if [ ! -f /etc/rc.local ]; then
            echo '#!/bin/bash' | sudo tee /etc/rc.local
            echo 'exit 0' | sudo tee -a /etc/rc.local
            sudo chmod +x /etc/rc.local
        fi
        # 在 exit 0 之前插入命令
        sudo sed -i "/exit 0/i echo heartbeat > $LED_PATH/trigger" /etc/rc.local
    fi
    echo ">>> 红灯已设置为心跳模式 (Heartbeat) - 它是你的生命探测仪。"
else
    echo ">>> 警告: 未找到红色 LED 设备，跳过灯语配置。"
fi

echo "---------------------------------------------------------"

echo ">>> [2/2] 配置硬件看门狗 (Watchdog)..."

# 2. 安装服务
sudo apt update
sudo apt install -y watchdog

# 3. 配置参数 (防误杀优化)
CONFIG_FILE="/etc/watchdog.conf"
sudo cp $CONFIG_FILE ${CONFIG_FILE}.bak

# 启用硬件设备
sudo sed -i 's/#watchdog-device/watchdog-device/g' $CONFIG_FILE

# [防误杀策略 1] 调高负载阈值 (防止编译时误判)
# 设为 24 (意味着负载到了 24 才会重启，编译时通常在 4-10 之间)
sudo sed -i 's/#max-load-1\s*=.*/max-load-1 = 24/' $CONFIG_FILE

# [防误杀策略 2] 赋予最高优先级 (Realtime Priority)
# 即使 CPU 100%，也要保证看门狗进程能运行，避免因"饿死"导致重启
sudo sed -i 's/#realtime/realtime/g' $CONFIG_FILE
sudo sed -i 's/#priority/priority/g' $CONFIG_FILE

# 4. 启动服务
sudo systemctl enable watchdog
sudo systemctl restart watchdog

echo ">>> 看门狗已启动！"
echo "    - 监控对象: 系统死锁 & 负载过高"
echo "    - 保护机制: 实时优先级 (防止编译误杀)"