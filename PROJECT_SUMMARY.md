# MySQL Express SQL Queries - Complete Project

## 🎯 Project Summary

A comprehensive Docker-based Express.js application demonstrating **10 different SQL query patterns** from simple SELECT statements to advanced JOINs, aggregations, and subqueries. Every line of code is thoroughly commented for educational purposes.

## 📦 What's Included

### Core Application Files

| File | Description |
|------|-------------|
| `src/app.js` | Main Express application with 10 API endpoints demonstrating SQL queries. **23KB**, fully commented |
| `package.json` | Node.js dependencies and scripts |
| `init.sql` | Database schema and sample data with 20 students, 19 courses, 80+ enrollments |

### Docker Configuration

| File | Description |
|------|-------------|
| `Dockerfile` | Container definition for Express app |
| `docker-compose.yml` | Multi-container orchestration (Express + MySQL) |
| `.dockerignore` | Files to exclude from Docker build |

### Database Configuration

| File | Description |
|------|-------------|
| `mysql-config/custom.cnf` | Optimized MySQL configuration for development |
| `init.sql` | Complete database schema with foreign keys, indexes, and sample data |

### Documentation

| File | Purpose | Size |
|------|---------|------|
| `README.md` | Comprehensive guide with all endpoints and examples | 12KB |
| `QUICKSTART.md` | Get started in 5 minutes | 5KB |
| `SQL_CONCEPTS.md` | Educational guide explaining SQL concepts | 14KB |
| `ARCHITECTURE.md` | System architecture and design decisions | 13KB |

### Testing & Tools

| File | Description |
|------|-------------|
| `test_api.sh` | Automated test script for all endpoints |
| `postman_collection.json` | Importable Postman collection for API testing |
| `.env.example` | Example environment variables |

## 🚀 Quick Start

```bash
# Navigate to project directory
cd mysql-express-app

# Start all services
docker-compose up -d

# Wait 30 seconds for initialization

# Test the application
curl http://localhost:3000/health

# View API documentation
curl http://localhost:3000/
```

## 📚 Learning Path

### Beginner (⭐)
1. Simple WHERE clause - `/api/students/grade/10`
2. Basic GROUP BY - `/api/analytics/students-per-grade`

### Intermediate (⭐⭐⭐)
3. INNER JOIN - `/api/students/1/enrollments`
4. LEFT JOIN - `/api/students/all-with-enrollments`
5. GROUP BY with HAVING - `/api/courses/popular/3`

### Advanced (⭐⭐⭐⭐⭐)
6. Complex JOIN with multiple conditions - `/api/analytics/student-performance`
7. Subqueries - `/api/students/in-courses?courseIds=1,2,3`
8. CASE statements - `/api/analytics/course-details/1`
9. Weighted aggregations - `/api/analytics/top-performers`
10. Department analytics - `/api/analytics/departments`

## 📊 Database Schema

### Tables
- **students** (20 records): Student information with grades 9-12
- **courses** (19 records): Courses across 5 departments
- **enrollments** (80+ records): Student-course relationships with grades

### Relationships
```
students (1) ──< enrollments (N) >── (1) courses
```

## 🔍 SQL Concepts Covered

1. ✅ SELECT with WHERE
2. ✅ INNER JOIN (multiple tables)
3. ✅ LEFT JOIN
4. ✅ GROUP BY
5. ✅ HAVING clause
6. ✅ Aggregate functions (COUNT, SUM, AVG, MIN, MAX)
7. ✅ CASE statements
8. ✅ Subqueries (scalar, row, table)
9. ✅ GROUP_CONCAT
10. ✅ Complex aggregations with weighted calculations
11. ✅ Multiple JOINs in single query
12. ✅ Conditional aggregation
13. ✅ Parameterized queries (SQL injection prevention)

## 🛠️ Technology Stack

- **Backend**: Node.js v18 (LTS)
- **Framework**: Express.js
- **Database**: MySQL 8.0
- **Logging**: Winston + Morgan
- **Containerization**: Docker + Docker Compose
- **Language**: JavaScript

## 📁 Project Structure

```
mysql-express-app/
├── src/
│   └── app.js                 # Main application (23KB, fully commented)
├── mysql-config/
│   └── custom.cnf             # MySQL optimization
├── logs/                      # Auto-created for application logs
├── init.sql                   # Database initialization
├── Dockerfile                 # Express app container
├── docker-compose.yml         # Multi-container setup
├── package.json               # Dependencies
├── test_api.sh               # Test script
├── postman_collection.json   # Postman API tests
├── README.md                 # Main documentation
├── QUICKSTART.md             # 5-minute setup guide
├── SQL_CONCEPTS.md           # SQL learning guide
├── ARCHITECTURE.md           # System architecture
├── .env.example              # Environment template
├── .dockerignore             # Docker exclusions
└── .gitignore               # Git exclusions
```

## 🎓 Educational Features

### Code Quality
- ✅ Every line commented and explained
- ✅ Consistent naming conventions
- ✅ Error handling on all endpoints
- ✅ Input validation and sanitization
- ✅ Parameterized queries (no SQL injection)

### Production Practices
- ✅ Health checks for both services
- ✅ Comprehensive logging (Winston)
- ✅ Connection pooling
- ✅ Environment-based configuration
- ✅ Non-root container user
- ✅ Proper volume management
- ✅ Network isolation

### Learning Resources
- ✅ 10 endpoints with increasing complexity
- ✅ Real-world school database example
- ✅ Query explanations in documentation
- ✅ Practice exercises suggested
- ✅ Postman collection for hands-on testing

## 🔧 Available Commands

```bash
# Start application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop application
docker-compose down

# Reset database (fresh start)
docker-compose down -v && docker-compose up -d

# Run tests
./test_api.sh

# Access MySQL directly
docker-compose exec mysql mysql -u root -p school_db
# Password: rootpassword

# View application logs
docker-compose exec app cat logs/combined.log
```

## 📊 Sample Data Statistics

- **Students**: 20 (distributed across grades 9-12)
- **Courses**: 19 (5 departments: Math, Science, English, Social Studies, Arts, PE)
- **Enrollments**: 80+ with realistic grade distributions
- **Average courses per student**: 4-5
- **GPA range**: 0.0 - 4.0

## 🎯 Use Cases

### For Students
- Learn SQL from basic to advanced
- See real-world query patterns
- Understand JOIN operations
- Practice with realistic data

### For Educators
- Teaching SQL fundamentals
- Demonstrating database design
- Showing best practices
- Hands-on exercises

### For Developers
- Reference for Express + MySQL integration
- Docker deployment patterns
- API design examples
- Logging and monitoring setup

## 🔒 Security Features

1. **SQL Injection Prevention**: All queries use parameterized values
2. **Container Security**: Non-root user, minimal base image
3. **Network Isolation**: Custom Docker network
4. **Input Validation**: Parameter validation on all endpoints
5. **Error Handling**: No sensitive data in error messages

## 📈 Performance Optimizations

1. **Database Indexes**: On frequently queried columns (grade, email, etc.)
2. **Connection Pooling**: Reuse database connections
3. **Query Optimization**: Efficient JOINs and aggregations
4. **Health Checks**: Automatic failure detection
5. **Logging Levels**: Configurable verbosity

## 🌟 Highlights

- ⚡ **Fast Setup**: Up and running in < 2 minutes
- 📖 **Well Documented**: 40KB+ of documentation
- 🧪 **Fully Tested**: Automated test script included
- 🎓 **Educational**: Every concept explained
- 🏗️ **Production Ready**: Docker, logging, health checks
- 🔍 **Real Examples**: 80+ realistic enrollments
- 🛠️ **Developer Friendly**: Postman collection, clear API

## 📞 Support Resources

1. **QUICKSTART.md** - Get started immediately
2. **README.md** - Complete API reference
3. **SQL_CONCEPTS.md** - Learn SQL concepts
4. **ARCHITECTURE.md** - Understand the system
5. **Inline Comments** - Every line explained

## 🎓 Learning Outcomes

After using this application, you will understand:

✅ Basic SQL SELECT and filtering  
✅ Table relationships and foreign keys  
✅ INNER vs LEFT JOINs  
✅ Grouping and aggregating data  
✅ Filtering aggregated results with HAVING  
✅ Conditional logic with CASE  
✅ Subqueries and correlated subqueries  
✅ Complex calculations and weighted averages  
✅ Query optimization techniques  
✅ Database design best practices  

## 📝 Next Steps

1. **Read QUICKSTART.md** to get the app running
2. **Follow the learning path** (⭐ to ⭐⭐⭐⭐⭐)
3. **Study SQL_CONCEPTS.md** for deeper understanding
4. **Modify queries** to experiment
5. **Try the practice exercises**
6. **Import Postman collection** for easy testing

---

**Built for learning SQL with practical, real-world examples!** 🚀

**Total Project Size**: ~110KB of code and documentation  
**Lines of Code**: ~900 (fully commented)  
**Documentation**: ~40KB  
**Ready to Deploy**: Yes ✅  
**Ready to Learn**: Yes ✅  
