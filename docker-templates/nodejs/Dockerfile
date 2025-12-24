# Node.js ARM64 构建模板 (中国特供版)
# 适用: Orange Pi, Raspberry Pi (ARM64)

# --- 阶段一: 构建环境 (Builder) ---
FROM node:18-alpine AS builder

WORKDIR /app

# [关键步骤] 设置 npm 淘宝镜像源 (npmmirror)
# 这能让你的构建速度提升 10 倍
RUN npm config set registry https://registry.npmmirror.com

# 1. 先复制依赖描述文件 (利用缓存)
COPY package.json package-lock.json* ./

# 2. 安装依赖
RUN npm install

# 3. 复制源码并编译
COPY . .
RUN npm run build

# --- 阶段二: 运行环境 (Runner) ---
# 这是一个精简的生产环境
FROM node:18-alpine

WORKDIR /app

# 从构建阶段复制产物
COPY --from=builder /app/.output ./.output
# (注意: 如果不是 Nuxt/Next 项目，这里可能需要调整为 COPY --from=builder /app/dist ./dist)

EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]