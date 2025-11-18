#!/bin/bash
set -e

echo "Starting Recipe API..."

# 如果提供了 Render 数据库环境变量，构建 JDBC URL
if [ -n "$DB_HOST" ]; then
  echo "Configuring database connection..."
  echo "DB_HOST: $DB_HOST"
  echo "DB_PORT: $DB_PORT"
  echo "DB_NAME: $DB_NAME"
  echo "DB_USER: $DB_USER"

  export JDBC_DATABASE_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&connectTimeout=30000&socketTimeout=30000"
  export DATABASE_USER="$DB_USER"
  export DATABASE_PASSWORD="$DB_PASSWORD"

  echo "JDBC_DATABASE_URL: $JDBC_DATABASE_URL"

  # 等待数据库准备就绪
  echo "Waiting for database to be ready..."
  max_attempts=30
  attempt=1

  while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt of $max_attempts..."

    # 使用 nc 或 timeout 测试数据库连接
    if command -v nc &> /dev/null; then
      if nc -z -w5 "$DB_HOST" "$DB_PORT"; then
        echo "Database is ready!"
        break
      fi
    elif command -v timeout &> /dev/null; then
      if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$DB_HOST/$DB_PORT"; then
        echo "Database is ready!"
        break
      fi
    else
      # 如果没有可用的测试工具，等待固定时间
      echo "No test tool available, waiting 10 seconds..."
      sleep 10
      break
    fi

    if [ $attempt -eq $max_attempts ]; then
      echo "ERROR: Database is not ready after $max_attempts attempts"
      exit 1
    fi

    echo "Database not ready, waiting 2 seconds..."
    sleep 2
    attempt=$((attempt + 1))
  done
else
  echo "Using local database configuration"
fi

echo "Starting application on port ${PORT:-9000}..."
# 启动应用
exec target/universal/stage/bin/recipe-api -Dhttp.port=${PORT:-9000}
