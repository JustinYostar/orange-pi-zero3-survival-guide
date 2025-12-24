# 系统备份与恢复指南 (Disaster Recovery)

> **警告**：SD 卡是有寿命的！对于配置了透明网桥和 Docker 的复杂系统，**定期全盘冷备份**是必须的。

## 🛠️ 准备工具

* **软件**: [Win32DiskImager](https://sourceforge.net/projects/win32diskimager/) (Windows 推荐) 或 `dd` 命令 (Linux/Mac)。
* **硬件**: SD 卡读卡器。

---

## 💾 备份步骤 (Backup)

**场景**：系统配置完美，准备封存一个“快照”。

1.  **关机**：
    ```bash
    sudo shutdown -h now
    ```
    *等板子上的绿灯熄灭后，拔掉电源。*

2.  **连接电脑**：
    拔出 SD 卡，插入读卡器，插到 Windows 电脑上。
    *(注意：Windows 可能会提示“需要格式化驱动器”，**千万点取消**！这是因为它读不懂 Linux 分区。)*

3.  **读取镜像 (Read)**：
    * 打开 **Win32DiskImager**。
    * **Image File**: 选择一个保存路径，并起名为 `opi-backup-202X-XX-XX.img`。
    * **Device**: 选择你的 SD 卡盘符。
    * 点击 **[Read]** 按钮。
    * *等待进度条走完，你将得到一个与 SD 卡容量一样大的 .img 文件。*

---

## ♻️ 恢复步骤 (Restore)

**场景**：SD 卡损坏，或者系统玩挂了无法启动。

1.  **准备新卡**：
    准备一张容量**不小于**原卡的新 SD 卡。

2.  **写入镜像 (Write)**：
    * 打开 **Win32DiskImager**。
    * **Image File**: 选择你之前备份的 `.img` 文件。
    * **Device**: 选择新 SD 卡的盘符。
    * 点击 **[Write]** 按钮。
    * *警告：这会清空卡内所有数据。*

3.  **上机**：
    写入完成后，把卡插回 Orange Pi，通电。
    你会发现系统完全回到了备份时的状态，连 IP 地址和 Docker 容器都一模一样。

---

## 🧹 进阶：定期清理 Docker

为了防止备份文件过大（虽然冷备份是全盘拷贝，但清理垃圾是好习惯），建议定期运行：

```bash
# 删除停止的容器、无用的镜像和构建缓存
docker system prune -a