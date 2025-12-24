# Deno ARM64 构建模板
# 优势: 不需要 package.json，且 Deno 官方镜像支持 ARM64

FROM denoland/deno:alpine

WORKDIR /app

# 1. 缓存依赖 (如果有 deps.ts)
# COPY deps.ts .
# RUN deno cache deps.ts

# 2. 复制代码
COPY . .

# 3. 编译/缓存主程序
RUN deno cache main.ts

# 权限设置 (按需开启)
# --allow-net: 允许网络
# --allow-read: 允许读文件
CMD ["run", "--allow-net", "--allow-read", "main.ts"]