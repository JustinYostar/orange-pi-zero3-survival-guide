# 第五步：系统清理与终极优化 (Final Optimization) 

> **核心任务**：防止 SD 卡空间耗尽，延长寿命，保持系统轻快。
---
## 🧹 1. 限制系统日志大小 (Systemd Journal) 

Linux 默认的日志记录非常激进，可能会在几个月内吃掉几个 G 的空间。
### 1.1 查看当前日志占用
```bash
journalctl --disk-usage
```
### 1.2 限制最大占用

编辑配置文件：`sudo nano /etc/systemd/journald.conf`

取消注释并修改 `SystemMaxUse`：

Ini, TOML

```
[Journal]
# 限制日志总大小不超过 100M
SystemMaxUse=100M
```

重启日志服务：

Bash

```
sudo systemctl restart systemd-journald
```

---

## 🐳 2. Docker 垃圾清理 (必做)

Docker 在构建和运行过程中会产生大量“悬空镜像”和缓存。

### 2.1 每日自动清理 (Cronjob)

我们可以设置一个定时任务，每周清理一次 Docker 垃圾。

输入 `crontab -e`，添加一行：

Bash

```
# 每周日凌晨 5 点清理所有停止的容器和未使用的镜像
0 5 * * 0 docker system prune -af --volumes > /dev/null 2>&1
```

### 2.2 手动清理命令

感觉空间不够时，直接运行：

Bash

```
# 警告：这会删除所有停止的容器
docker system prune -a
```

---

## 💾 3. 最终备份 (封存)

到现在为止，你的 Orange Pi Zero 3 已经配置了：

- ✅ 完美的 Swap 与内核锁
    
- ✅ NAT 网关 + DHCP
    
- ✅ ShellCrash 科学上网
    
- ✅ AdGuard Home 去广告
    
- ✅ 你的私人 Docker 应用
    

**现在的状态是最完美的。请务必做一次全盘冷备份！**

1. 关机：`sudo shutdown -h now`
    
2. 拔卡插电脑。
    
3. 使用 **Win32DiskImager** 读取为 `.img` 文件。
    
4. 将这个文件命名为 `OpiZero3_Perfect_Setup.img` 妥善保存。
    

---

## 🎉 结语

恭喜！你已经把一块 100 多块钱的开发板，变成了一个**集网关、服务器、测试环境于一体的微型怪兽**。

Keep building, keep hacking! 🚀