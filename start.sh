#!/bin/bash
set -e

echo "Starting Recipe API..."
echo "================================"
echo "Environment Variables Debug:"
echo "PORT: $PORT"
echo "DATABASE_URL: ${DATABASE_URL:0:20}... (masked)"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DB_PASSWORD: ${DB_PASSWORD:0:3}*** (masked)"
echo "================================"

# 优先使用 Render 自动提供的 DATABASE_URL
if [ -n "$DATABASE_URL" ]; then
  echo "Using DATABASE_URL from Render..."

  # 从 DATABASE_URL 中提取主机和端口用于连接测试
  # 格式: postgresql://user:pass@host:port/dbname
  DB_HOST=$(echo "$DATABASE_URL" | sed -n 's|postgresql://[^@]*@\([^:]*\).*|\1|p')
  DB_PORT=$(echo "$DATABASE_URL" | sed -n 's|postgresql://[^@]*@[^:]*:\([0-9]*\).*|\1|p')

  # 如果没有提取到端口，使用默认值
  if [ -z "$DB_PORT" ]; then
    DB_PORT=5432
  fi

  echo "Extracted DB_HOST: $DB_HOST"
  echo "Extracted DB_PORT: $DB_PORT"

  # 将 postgresql:// 转换为 jdbc:postgresql://
  export JDBC_DATABASE_URL=$(echo "$DATABASE_URL" | sed 's|^postgresql://|jdbc:postgresql://|')
  # 添加 SSL 配置
  if [[ "$JDBC_DATABASE_URL" != *"?"* ]]; then
    export JDBC_DATABASE_URL="${JDBC_DATABASE_URL}?sslmode=require"
  else
    export JDBC_DATABASE_URL="${JDBC_DATABASE_URL}&sslmode=require"
  fi
  echo "JDBC_DATABASE_URL: ${JDBC_DATABASE_URL:0:40}... (masked)"

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

  echo "Database configuration successful!"
# 如果提供了单独的数据库环境变量
elif [ -n "$DB_HOST" ]; then
  echo "Configuring database connection..."
  echo "DB_HOST: $DB_HOST"
  echo "DB_PORT: $DB_PORT"
  echo "DB_NAME: $DB_NAME"
  echo "DB_USER: $DB_USER"

  export JDBC_DATABASE_URL="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=require&connectTimeout=30"
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
