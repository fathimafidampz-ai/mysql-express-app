# Quick Start Guide

Get started with the MySQL Express SQL Queries application in 5 minutes!

## Prerequisites

You only need **Docker Desktop** installed on your computer.

- [Download Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- [Download Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
- [Download Docker Desktop for Linux](https://docs.docker.com/desktop/install/linux-install/)

## Step 1: Navigate to Project Directory

```bash
cd mysql-express-app
```

## Step 2: Start the Application

```bash
docker-compose up -d
```

This command will:
- Download MySQL and Node.js images (first time only)
- Create and start MySQL database container
- Create and start Express application container
- Initialize database with sample data

**Wait for 30-60 seconds** for services to fully start.

## Step 3: Verify Installation

Open your web browser and visit:

```
http://localhost:3000
```

You should see the API documentation page with a list of all endpoints.

### Or use curl:

```bash
curl http://localhost:3000/health
```

You should see:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-01-04T..."
}
```

## Step 4: Try Some Queries!

### Example 1: Get all students in grade 10

**Browser**: http://localhost:3000/api/students/grade/10

**curl**:
```bash
curl http://localhost:3000/api/students/grade/10
```

### Example 2: View course analytics

**Browser**: http://localhost:3000/api/analytics/departments

**curl**:
```bash
curl http://localhost:3000/api/analytics/departments
```

### Example 3: Find top performers

**Browser**: http://localhost:3000/api/analytics/top-performers?minCourses=3&minGPA=3.5

**curl**:
```bash
curl "http://localhost:3000/api/analytics/top-performers?minCourses=3&minGPA=3.5"
```

## Step 5: Run All Tests (Optional)

```bash
./test_api.sh
```

This will test all endpoints and show results.

## Viewing Logs

### Application Logs

```bash
# View all logs
docker-compose logs

# View only Express app logs
docker-compose logs app

# Follow logs in real-time
docker-compose logs -f app
```

### Inside Container Logs

```bash
# View application logs (winston)
docker-compose exec app cat logs/combined.log

# View errors only
docker-compose exec app cat logs/error.log
```

## Accessing the Database

```bash
# Connect to MySQL
docker-compose exec mysql mysql -u root -p school_db
# Password: rootpassword
```

Inside MySQL:
```sql
-- View all students
SELECT * FROM students LIMIT 10;

-- View all courses
SELECT * FROM courses;

-- View enrollments
SELECT * FROM enrollments LIMIT 10;

-- Exit
EXIT;
```

## Common Commands

### Check Service Status

```bash
docker-compose ps
```

### Stop the Application

```bash
docker-compose down
```

### Restart Services

```bash
docker-compose restart
```

### View Container Logs

```bash
docker-compose logs -f
```

### Reset Database (Fresh Start)

```bash
# Stop and remove everything including data
docker-compose down -v

# Start fresh
docker-compose up -d
```

## Troubleshooting

### Port Already in Use

If you see "port is already allocated" error:

1. **Check what's using the port**:
   ```bash
   # On Linux/Mac
   lsof -i :3000
   lsof -i :3306
   
   # On Windows
   netstat -ano | findstr :3000
   netstat -ano | findstr :3306
   ```

2. **Stop the conflicting service** or **change the port** in `docker-compose.yml`

### Services Not Starting

```bash
# View detailed logs
docker-compose logs

# Remove and rebuild
docker-compose down -v
docker-compose up -d --build
```

### Database Connection Failed

```bash
# Check if MySQL is healthy
docker-compose ps

# Restart MySQL
docker-compose restart mysql

# Wait 30 seconds and try again
```

## Next Steps

1. **Read the README.md** for detailed documentation
2. **Import Postman collection** (`postman_collection.json`) for easy testing
3. **Explore the code** in `src/app.js` - every line is commented!
4. **Modify queries** and experiment with different SQL patterns

## Learning Path

**Beginners**: Start with simple endpoints (⭐)
- `/api/students/grade/:grade`
- `/api/analytics/students-per-grade`

**Intermediate**: Try JOIN queries (⭐⭐⭐)
- `/api/students/:id/enrollments`
- `/api/students/all-with-enrollments`
- `/api/courses/popular/:minEnrollments`

**Advanced**: Challenge yourself (⭐⭐⭐⭐⭐)
- `/api/analytics/top-performers`
- `/api/analytics/course-details/:courseId`
- `/api/analytics/departments`

## Get Help

Check the main **README.md** file for:
- Detailed API documentation
- SQL concepts explained
- Complete endpoint reference
- Advanced troubleshooting

---

**Happy Learning! 🚀**
