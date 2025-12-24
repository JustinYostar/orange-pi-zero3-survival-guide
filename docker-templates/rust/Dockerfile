# Rust ARM64 构建模板 (中国特供版)
# 适用: Orange Pi, Raspberry Pi (ARM64)

FROM rust:alpine AS builder

WORKDIR /app

# [关键步骤 1] 配置 rustup 更新源 (中科大 USTC)
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

# 安装基础编译工具 (musl-dev 是 Alpine 编译 Rust 必须的)
RUN apk add --no-cache musl-dev

# [关键步骤 2] 配置 Crates.io 镜像源 (解决 cargo build 慢)
# 在构建前创建 config 文件
RUN mkdir -p $HOME/.cargo && \
    echo '[source.crates-io]' > $HOME/.cargo/config && \
    echo 'replace-with = "ustc"' >> $HOME/.cargo/config && \
    echo '[source.ustc]' >> $HOME/.cargo/config && \
    echo 'registry = "git://mirrors.ustc.edu.cn/crates.io-index"' >> $HOME/.cargo/config

# 1. 创建一个空的 main.rs 来预编译依赖 (利用 Docker 缓存)
RUN mkdir src && echo "fn main() {}" > src/main.rs
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release

# 2. 复制真正的源码并编译
COPY . .
# 更新文件时间戳，确保重新编译
RUN touch src/main.rs
RUN cargo build --release

# --- 运行阶段 ---
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/target/release/app_name .
CMD ["./app_name"]