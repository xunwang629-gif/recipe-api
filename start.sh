#!/bin/bash
set -e

# 如果提供了 Render 数据库环境变量，构建 JDBC URL
if [ -n "$DB_HOST" ]; then
  export JDBC_DATABASE_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
  export DATABASE_USER="$DB_USER"
  export DATABASE_PASSWORD="$DB_PASSWORD"
fi

# 启动应用
exec target/universal/stage/bin/recipe-api -Dhttp.port=${PORT:-9000}
