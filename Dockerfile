FROM eclipse-temurin:11-jdk

WORKDIR /app

# 安装基础工具和 PostgreSQL 客户端
RUN apt-get update && \
    apt-get install -y curl netcat-openbsd postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# 直接下载并安装 sbt（不依赖 keyserver）
RUN curl -L -o sbt.tgz https://github.com/sbt/sbt/releases/download/v1.9.7/sbt-1.9.7.tgz && \
    tar -xzf sbt.tgz -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/bin/sbt && \
    rm sbt.tgz

# 复制项目文件
COPY . .

# 清理并构建项目（确保不使用旧的缓存）
RUN sbt clean stage

# 添加启动脚本执行权限
RUN chmod +x start.sh

# 暴露端口 (Render 使用动态端口)
EXPOSE ${PORT:-9000}

# 使用启动脚本
CMD ["./start.sh"]