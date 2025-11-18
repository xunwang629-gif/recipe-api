# Recipe API

A RESTful API for managing recipes, built with Play Framework and Scala.

## Features

- Create, read, update, and delete recipes
- MySQL database with UTF-8 support
- Database migrations with Play Evolutions
- RESTful JSON API

## Tech Stack

- **Framework**: Play Framework 3.0.9
- **Language**: Scala 2.13.17
- **Database**: MySQL 8.0
- **Build Tool**: sbt 1.11.7

## Prerequisites

- Java 17 or higher
- Docker (for MySQL)
- sbt

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/xunwang629-gif/recipe-api.git
cd recipe-api
```

### 2. Start MySQL with Docker

```bash
docker run -d \
  --name recipe-mysql \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=recipe_db \
  -p 3306:3306 \
  mysql:8.0 \
  --character-set-server=utf8 \
  --collation-server=utf8_unicode_ci
```

### 3. Run the application

```bash
sbt run
```

The API will be available at `http://localhost:9000`

## API Endpoints

### Get all recipes
```bash
GET /recipes
```

**Response:**
```json
{
  "recipes": [
    {
      "id": 1,
      "title": "Chicken Curry",
      "making_time": "45 min",
      "serves": "4 people",
      "ingredients": "onion, chicken, seasoning",
      "cost": "1000"
    }
  ]
}
```

### Get a recipe by ID
```bash
GET /recipes/:id
```

### Create a new recipe
```bash
POST /recipes
Content-Type: application/json

{
  "title": "Tomato Soup",
  "making_time": "15 min",
  "serves": "2 people",
  "ingredients": "tomato, onion, garlic",
  "cost": 500
}
```

### Update a recipe
```bash
PATCH /recipes/:id
Content-Type: application/json

{
  "title": "Updated Recipe Title",
  "cost": 600
}
```

### Delete a recipe
```bash
DELETE /recipes/:id
```

## Database Schema

```sql
CREATE TABLE recipes (
  id integer PRIMARY KEY AUTO_INCREMENT,
  title varchar(100) NOT NULL,
  making_time varchar(100) NOT NULL,
  serves varchar(100) NOT NULL,
  ingredients varchar(300) NOT NULL,
  cost integer NOT NULL,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Configuration

Database configuration is in `conf/application.conf`:

```conf
db.default.driver=com.mysql.cj.jdbc.Driver
db.default.url="jdbc:mysql://localhost:3306/recipe_db?useSSL=false&serverTimezone=UTC"
db.default.username="root"
db.default.password="root"
```

## Development

### Run tests
```bash
sbt test
```

### Build for production
```bash
sbt dist
```

This will create a deployable zip file in `target/universal/`

## Deployment

See the full deployment guide in the project documentation for deploying to:
- Cloud servers (AWS, GCP, DigitalOcean)
- PaaS platforms (Heroku, Railway, Render)
- Container platforms (Docker, Kubernetes)

## License

This project is open source and available under the MIT License.
