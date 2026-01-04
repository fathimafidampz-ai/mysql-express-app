# MySQL Express SQL Queries Demo

A comprehensive Docker-based Express.js application demonstrating various SQL query patterns with MySQL, from simple SELECT statements to advanced JOINs, aggregations, and subqueries.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [API Endpoints](#api-endpoints)
- [Query Examples](#query-examples)
- [Database Schema](#database-schema)
- [Project Structure](#project-structure)
- [Development](#development)
- [Troubleshooting](#troubleshooting)

## ✨ Features

- **Simple to Advanced SQL Queries**: Demonstrates 10 different query patterns
- **Comprehensive Logging**: Winston logger with file and console output
- **Docker Containerization**: Easy setup with Docker Compose
- **Health Checks**: Built-in health monitoring for both services
- **Production Ready**: Includes error handling, security best practices
- **Well Commented Code**: Every line of code is documented

## 🔧 Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- Any REST client (Postman, curl, or web browser)

## 🚀 Quick Start

### 1. Clone or Download

```bash
cd mysql-express-app
```

### 2. Start the Application

```bash
# Start all services (MySQL + Express)
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### 3. Verify Installation

```bash
# Health check
curl http://localhost:3000/health

# View API documentation
curl http://localhost:3000/
```

### 4. Stop the Application

```bash
# Stop services
docker-compose down

# Stop and remove volumes (clears database)
docker-compose down -v
```

## 📡 API Endpoints

### Base URL: `http://localhost:3000`

| Endpoint | Method | Description | Query Complexity |
|----------|--------|-------------|------------------|
| `/health` | GET | Health check | - |
| `/` | GET | API documentation | - |
| `/api/students/grade/:grade` | GET | Simple WHERE clause | ⭐ |
| `/api/students/:studentId/enrollments` | GET | INNER JOIN | ⭐⭐ |
| `/api/students/all-with-enrollments` | GET | LEFT JOIN + GROUP BY | ⭐⭐ |
| `/api/analytics/students-per-grade` | GET | GROUP BY + COUNT | ⭐⭐ |
| `/api/courses/popular/:minEnrollments` | GET | GROUP BY + HAVING | ⭐⭐⭐ |
| `/api/analytics/student-performance` | GET | Complex JOIN + WHERE + GROUP BY + HAVING | ⭐⭐⭐⭐ |
| `/api/students/in-courses` | GET | Subquery with WHERE IN | ⭐⭐⭐ |
| `/api/analytics/course-details/:courseId` | GET | Advanced CASE + Multiple JOINs | ⭐⭐⭐⭐ |
| `/api/analytics/top-performers` | GET | Complex Aggregation + HAVING | ⭐⭐⭐⭐⭐ |
| `/api/analytics/departments` | GET | Department Analytics | ⭐⭐⭐⭐ |

## 📊 Query Examples

### 1. Simple WHERE Query (⭐)

**Endpoint**: `GET /api/students/grade/10`

**SQL Concept**: Basic SELECT with WHERE clause

```sql
SELECT student_id, first_name, last_name, email, grade, enrollment_date
FROM students
WHERE grade = 10
ORDER BY last_name, first_name
```

**Example Request**:
```bash
curl http://localhost:3000/api/students/grade/10
```

---

### 2. INNER JOIN (⭐⭐)

**Endpoint**: `GET /api/students/1/enrollments`

**SQL Concept**: Joining multiple tables to get related data

```sql
SELECT s.student_id, s.first_name, s.last_name,
       c.course_id, c.course_name, c.credits,
       e.enrollment_date, e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE s.student_id = 1
```

**Example Request**:
```bash
curl http://localhost:3000/api/students/1/enrollments
```

---

### 3. LEFT JOIN with GROUP BY (⭐⭐)

**Endpoint**: `GET /api/students/all-with-enrollments`

**SQL Concept**: Get all students including those without enrollments

```sql
SELECT s.student_id, s.first_name, s.last_name,
       COUNT(e.enrollment_id) as total_enrollments,
       GROUP_CONCAT(c.course_name) as courses
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id
GROUP BY s.student_id
```

**Example Request**:
```bash
curl http://localhost:3000/api/students/all-with-enrollments
```

---

### 4. GROUP BY with Aggregation (⭐⭐)

**Endpoint**: `GET /api/analytics/students-per-grade`

**SQL Concept**: Counting and grouping data

```sql
SELECT grade, COUNT(*) as student_count
FROM students
GROUP BY grade
ORDER BY grade
```

**Example Request**:
```bash
curl http://localhost:3000/api/analytics/students-per-grade
```

---

### 5. HAVING Clause (⭐⭐⭐)

**Endpoint**: `GET /api/courses/popular/3`

**SQL Concept**: Filtering aggregated results with HAVING

```sql
SELECT c.course_id, c.course_name,
       COUNT(e.enrollment_id) as enrollment_count
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
HAVING COUNT(e.enrollment_id) >= 3
ORDER BY enrollment_count DESC
```

**Example Request**:
```bash
curl http://localhost:3000/api/courses/popular/3
```

---

### 6. Complex Query with Multiple Conditions (⭐⭐⭐⭐)

**Endpoint**: `GET /api/analytics/student-performance?minGPA=3.0&grade=10`

**SQL Concept**: Complex JOIN with WHERE, GROUP BY, and HAVING

```sql
SELECT s.student_id, s.first_name, s.last_name,
       COUNT(e.enrollment_id) as courses_taken,
       AVG(grade_points) as gpa
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
WHERE s.grade = 10
GROUP BY s.student_id
HAVING AVG(grade_points) >= 3.0
ORDER BY gpa DESC
```

**Example Request**:
```bash
curl "http://localhost:3000/api/analytics/student-performance?minGPA=3.0&grade=10"
```

---

### 7. Subquery with WHERE IN (⭐⭐⭐)

**Endpoint**: `GET /api/students/in-courses?courseIds=1,2,3`

**SQL Concept**: Using subqueries to filter results

```sql
SELECT DISTINCT s.*
FROM students s
WHERE s.student_id IN (
    SELECT student_id
    FROM enrollments
    WHERE course_id IN (1, 2, 3)
)
```

**Example Request**:
```bash
curl "http://localhost:3000/api/students/in-courses?courseIds=1,2,3"
```

---

### 8. Advanced CASE Statements (⭐⭐⭐⭐)

**Endpoint**: `GET /api/analytics/course-details/1`

**SQL Concept**: Conditional logic and complex aggregations

```sql
SELECT c.course_id, c.course_name,
       COUNT(DISTINCT e.student_id) as total_students,
       SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) as count_A,
       SUM(CASE WHEN e.grade = 'B' THEN 1 ELSE 0 END) as count_B,
       ROUND(SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as percent_A
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE c.course_id = 1
GROUP BY c.course_id
```

**Example Request**:
```bash
curl http://localhost:3000/api/analytics/course-details/1
```

---

### 9. Top Performers (⭐⭐⭐⭐⭐)

**Endpoint**: `GET /api/analytics/top-performers?minCourses=3&minGPA=3.5`

**SQL Concept**: Advanced aggregation with weighted GPA calculation

```sql
SELECT s.student_id, s.first_name, s.last_name,
       COUNT(DISTINCT e.course_id) as courses_completed,
       ROUND(SUM(grade_points * credits) / SUM(credits), 2) as weighted_gpa
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id
HAVING COUNT(DISTINCT e.course_id) >= 3 AND weighted_gpa >= 3.5
ORDER BY weighted_gpa DESC
```

**Example Request**:
```bash
curl "http://localhost:3000/api/analytics/top-performers?minCourses=3&minGPA=3.5"
```

---

### 10. Department Analytics (⭐⭐⭐⭐)

**Endpoint**: `GET /api/analytics/departments`

**SQL Concept**: Comprehensive departmental statistics

**Example Request**:
```bash
curl http://localhost:3000/api/analytics/departments
```

## 🗄️ Database Schema

### Students Table
```sql
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  grade INT NOT NULL,
  enrollment_date DATE NOT NULL
);
```

### Courses Table
```sql
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  course_name VARCHAR(100) NOT NULL,
  department VARCHAR(50) NOT NULL,
  credits INT NOT NULL,
  description TEXT
);
```

### Enrollments Table
```sql
CREATE TABLE enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  enrollment_date DATE NOT NULL,
  grade CHAR(1),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
```

## 📁 Project Structure

```
mysql-express-app/
├── src/
│   └── app.js              # Main Express application
├── logs/                   # Application logs (auto-created)
├── init.sql               # Database initialization script
├── Dockerfile             # Docker image definition
├── docker-compose.yml     # Multi-container orchestration
├── package.json           # Node.js dependencies
├── .dockerignore          # Files to exclude from Docker build
├── .gitignore            # Files to exclude from git
└── README.md             # This file
```

## 💻 Development

### Local Development (without Docker)

1. **Install MySQL locally**
2. **Run initialization script**:
   ```bash
   mysql -u root -p < init.sql
   ```
3. **Install dependencies**:
   ```bash
   npm install
   ```
4. **Set environment variables**:
   ```bash
   export DB_HOST=localhost
   export DB_USER=root
   export DB_PASSWORD=your_password
   export DB_NAME=school_db
   ```
5. **Start the application**:
   ```bash
   npm start
   # or for development with auto-reload
   npm run dev
   ```

### Viewing Logs

```bash
# Container logs
docker-compose logs -f app

# Application logs (inside container)
docker-compose exec app cat logs/combined.log

# Follow logs in real-time
docker-compose exec app tail -f logs/combined.log
```

### Database Access

```bash
# Connect to MySQL container
docker-compose exec mysql mysql -u root -p school_db
# Password: rootpassword

# Run SQL queries
mysql> SELECT * FROM students LIMIT 5;
mysql> SHOW TABLES;
mysql> DESC students;
```

### Rebuild Application

```bash
# Rebuild app container after code changes
docker-compose up -d --build app

# Rebuild everything
docker-compose up -d --build
```

## 🔧 Troubleshooting

### Port Already in Use

If port 3000 or 3306 is already in use:

**Option 1**: Stop the conflicting service

**Option 2**: Change ports in `docker-compose.yml`:
```yaml
services:
  app:
    ports:
      - "3001:3000"  # Use port 3001 instead
  mysql:
    ports:
      - "3307:3306"  # Use port 3307 instead
```

### Database Connection Failed

1. **Check MySQL is healthy**:
   ```bash
   docker-compose ps
   # mysql should show "healthy"
   ```

2. **Wait for MySQL initialization**:
   ```bash
   docker-compose logs mysql
   # Wait for: "ready for connections"
   ```

3. **Restart services**:
   ```bash
   docker-compose restart
   ```

### Reset Database

```bash
# Stop and remove volumes
docker-compose down -v

# Start fresh
docker-compose up -d
```

### View Container Logs

```bash
# All logs
docker-compose logs

# Specific service
docker-compose logs mysql
docker-compose logs app

# Follow logs
docker-compose logs -f
```

## 📝 SQL Concepts Covered

1. **SELECT with WHERE** - Basic filtering
2. **INNER JOIN** - Matching rows from multiple tables
3. **LEFT JOIN** - Include all rows from left table
4. **GROUP BY** - Aggregate data into groups
5. **HAVING** - Filter aggregated results
6. **COUNT, SUM, AVG** - Aggregate functions
7. **CASE WHEN** - Conditional logic
8. **Subqueries** - Nested queries
9. **GROUP_CONCAT** - String aggregation
10. **Complex Aggregations** - Weighted calculations

## 🎓 Learning Path

**Beginners**: Start with endpoints 1-4
**Intermediate**: Progress to endpoints 5-7
**Advanced**: Challenge yourself with endpoints 8-10

## 📄 License

MIT License - Feel free to use this for learning and education!

## 🤝 Contributing

This is an educational project. Feel free to:
- Add more query examples
- Improve documentation
- Add test cases
- Enhance error handling

---

**Built for learning SQL queries with practical examples!** 🚀
