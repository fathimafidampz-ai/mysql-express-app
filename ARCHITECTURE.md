# System Architecture

## Overview

This document describes the architecture of the MySQL Express SQL Queries application.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Docker Host                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                   Docker Network: app-network           │    │
│  │                                                         │    │
│  │  ┌─────────────────────┐      ┌──────────────────────┐│    │
│  │  │   Express App       │      │   MySQL 8.0          ││    │
│  │  │   Container         │      │   Container          ││    │
│  │  │                     │      │                      ││    │
│  │  │  ┌──────────────┐   │      │  ┌───────────────┐  ││    │
│  │  │  │   Node.js    │   │      │  │  Database:    │  ││    │
│  │  │  │   v18 LTS    │   │      │  │  school_db    │  ││    │
│  │  │  │              │   │      │  │               │  ││    │
│  │  │  │  Express.js  │◄──┼──────┼──┤  - students   │  ││    │
│  │  │  │  Framework   │   │      │  │  - courses    │  ││    │
│  │  │  │              │   │      │  │  - enrollments│  ││    │
│  │  │  │  mysql2      │   │      │  │               │  ││    │
│  │  │  │  winston     │   │      │  └───────────────┘  ││    │
│  │  │  │  morgan      │   │      │                      ││    │
│  │  │  └──────────────┘   │      └──────────────────────┘│    │
│  │  │                     │              │               │    │
│  │  │   Port: 3000        │         Port: 3306          │    │
│  │  └─────────┬───────────┘              │               │    │
│  │            │                           │               │    │
│  └────────────┼───────────────────────────┼───────────────┘    │
│               │                           │                    │
│               │    Volume Mounts          │                    │
│               │                           │                    │
│    ┌──────────▼───────────┐    ┌─────────▼──────────────┐    │
│    │  ./logs:/app/logs    │    │  mysql_data volume     │    │
│    │  (Log Files)         │    │  (Persistent DB Data)  │    │
│    └──────────────────────┘    └────────────────────────┘    │
│                                                                │
└────────────────────┬───────────────────────────────────────────┘
                     │
                     │  Exposed Ports
                     │
         ┌───────────▼────────────┐
         │   localhost:3000       │  ◄── HTTP API
         │   localhost:3306       │  ◄── MySQL (optional)
         └────────────────────────┘
```

## Component Details

### 1. Express Application Container

**Base Image**: `node:18-alpine`

**Responsibilities**:
- Handle HTTP requests
- Execute SQL queries
- Log operations
- Return JSON responses

**Dependencies**:
```json
{
  "express": "HTTP server framework",
  "mysql2": "MySQL client with promise support",
  "winston": "Logging library",
  "morgan": "HTTP request logger"
}
```

**Environment Variables**:
- `DB_HOST`: MySQL container hostname
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name
- `PORT`: Application port (default: 3000)
- `NODE_ENV`: Environment (production/development)

### 2. MySQL Database Container

**Base Image**: `mysql:8.0`

**Responsibilities**:
- Store application data
- Execute SQL queries
- Maintain data integrity

**Database Schema**:
- `students`: Student information
- `courses`: Course catalog
- `enrollments`: Student-course relationships

**Initialization**:
- Automatically runs `init.sql` on first startup
- Creates tables and inserts sample data

### 3. Docker Network

**Type**: Bridge network

**Purpose**: 
- Allows containers to communicate
- Provides DNS resolution (containers can reference each other by name)
- Isolates application from host network

### 4. Persistent Storage

**MySQL Data Volume**:
- Type: Named volume (`mysql_data`)
- Purpose: Persist database data across container restarts
- Location: Docker managed

**Logs Directory**:
- Type: Bind mount (`./logs`)
- Purpose: Access application logs from host
- Files: `combined.log`, `error.log`

## Request Flow

```
1. Client Request
   │
   ├─► http://localhost:3000/api/students/grade/10
   │
2. Express Router
   │
   ├─► Route matches: /api/students/grade/:grade
   │
3. Request Handler
   │
   ├─► Extract parameter: grade = 10
   ├─► Log request (Morgan + Winston)
   │
4. Database Query
   │
   ├─► Build SQL query with parameterized values
   ├─► Execute query via connection pool
   │
5. MySQL Processing
   │
   ├─► Parse SQL
   ├─► Optimize query
   ├─► Execute against indexes
   ├─► Return result set
   │
6. Response Processing
   │
   ├─► Format results as JSON
   ├─► Log response
   ├─► Send to client
   │
7. Client Receives
   │
   └─► JSON response with student data
```

## Data Flow

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │ HTTP Request
       ▼
┌──────────────────┐
│   Express App    │
│                  │
│  ┌────────────┐  │
│  │  Routing   │  │
│  └─────┬──────┘  │
│        │         │
│  ┌─────▼──────┐  │
│  │  Handler   │  │
│  └─────┬──────┘  │
│        │         │
│  ┌─────▼──────┐  │
│  │ SQL Query  │  │
│  └─────┬──────┘  │
└────────┼─────────┘
         │ SQL via mysql2
         ▼
┌──────────────────┐
│   MySQL DB       │
│                  │
│  ┌────────────┐  │
│  │   Query    │  │
│  │  Executor  │  │
│  └─────┬──────┘  │
│        │         │
│  ┌─────▼──────┐  │
│  │  Storage   │  │
│  │  Engine    │  │
│  └────────────┘  │
└──────────────────┘
         │ Result Set
         ▼
┌──────────────────┐
│   Express App    │
│  ┌────────────┐  │
│  │   Format   │  │
│  │    JSON    │  │
│  └─────┬──────┘  │
└────────┼─────────┘
         │ HTTP Response
         ▼
┌──────────────┐
│   Client     │
└──────────────┘
```

## API Endpoints Architecture

```
/api
├── /students
│   ├── /grade/:grade           (Simple WHERE)
│   ├── /:studentId/enrollments (INNER JOIN)
│   ├── /all-with-enrollments   (LEFT JOIN + GROUP BY)
│   └── /in-courses             (Subquery)
│
├── /courses
│   └── /popular/:minEnrollments (GROUP BY + HAVING)
│
└── /analytics
    ├── /students-per-grade      (GROUP BY)
    ├── /student-performance     (Complex JOIN + HAVING)
    ├── /course-details/:id      (Advanced CASE)
    ├── /top-performers          (Complex Aggregation)
    └── /departments             (Department Analytics)
```

## Database Schema

```
┌─────────────────────────┐
│      students           │
├─────────────────────────┤
│ PK student_id (INT)     │
│    first_name (VARCHAR) │
│    last_name (VARCHAR)  │
│    email (VARCHAR) UQ   │
│    grade (INT) IDX      │
│    enrollment_date      │
└───────────┬─────────────┘
            │
            │ 1:N
            │
┌───────────▼─────────────┐
│     enrollments         │
├─────────────────────────┤
│ PK enrollment_id (INT)  │
│ FK student_id (INT)     │
│ FK course_id (INT)      │
│    enrollment_date      │
│    grade (CHAR)         │
│                         │
│ UK (student_id,         │
│     course_id)          │
└───────────┬─────────────┘
            │
            │ N:1
            │
┌───────────▼─────────────┐
│       courses           │
├─────────────────────────┤
│ PK course_id (INT)      │
│    course_name (VARCHAR)│
│    department (VARCHAR) │
│    credits (INT)        │
│    description (TEXT)   │
└─────────────────────────┘
```

## Security Considerations

### 1. SQL Injection Prevention
```javascript
// ✅ Parameterized queries
pool.query('SELECT * FROM students WHERE grade = ?', [grade]);

// ❌ NEVER do this
pool.query(`SELECT * FROM students WHERE grade = ${grade}`);
```

### 2. Container Security
- Application runs as non-root user
- Minimal base image (Alpine Linux)
- No unnecessary packages

### 3. Network Isolation
- Application network is isolated
- Only necessary ports exposed
- Database not directly accessible from outside (unless needed)

### 4. Environment Variables
- Sensitive data in environment variables
- Not hardcoded in source code
- Can use Docker secrets for production

## Monitoring & Logging

### Application Logs
```
logs/
├── combined.log  (All logs)
└── error.log     (Errors only)
```

### Log Levels
- `error`: Errors that need attention
- `warn`: Warning messages
- `info`: Informational messages (default)
- `debug`: Detailed debugging information

### Health Checks
- **Express App**: `GET /health`
- **MySQL**: `mysqladmin ping`
- Docker automatically monitors both

## Scalability Considerations

### Horizontal Scaling
```
Load Balancer
      │
      ├─► Express App Instance 1 ─┐
      ├─► Express App Instance 2 ─┼─► MySQL (Single)
      └─► Express App Instance 3 ─┘
```

### Connection Pooling
- Maximum 10 concurrent connections
- Prevents database overload
- Reuses connections efficiently

### Caching Strategies (Future)
- Redis for frequently accessed data
- Query result caching
- Session management

## Development vs Production

### Development
- Debug logging enabled
- Source code mounted as volume
- Direct database access
- Detailed error messages

### Production
- Info-level logging
- Optimized Docker images
- Database isolated
- Generic error messages
- Health monitoring
- Auto-restart on failure

---

**This architecture provides a solid foundation for learning SQL while maintaining production-ready practices!** 🏗️
