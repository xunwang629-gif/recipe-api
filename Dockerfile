FROM eclipse-temurin:11-jdk

WORKDIR /app

# 安装 sbt
RUN apt-get update && \
    apt-get install -y curl && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
    apt-get update && \
    apt-get install -y sbt

# 复制项目文件
COPY . .

# 构建项目
RUN sbt stage

# 暴露端口
EXPOSE 9000

# 启动应用
CMD ["target/universal/stage/bin/recipe-api", "-Dhttp.port=$PORT"]