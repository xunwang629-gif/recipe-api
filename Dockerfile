FROM eclipse-temurin:11-jdk

WORKDIR /app

# 安装 sbt 和网络工具
RUN apt-get update && \
    apt-get install -y curl netcat-openbsd gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --dearmor -o /etc/apt/keyrings/sbt.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/sbt.gpg] https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    apt-get update && \
    apt-get install -y sbt && \
    rm -rf /var/lib/apt/lists/*

# 复制项目文件
COPY . .

# 构建项目
RUN sbt stage

# 添加启动脚本执行权限
RUN chmod +x start.sh

# 暴露端口 (Render 使用动态端口)
EXPOSE ${PORT:-9000}

# 使用启动脚本
CMD ["./start.sh"]