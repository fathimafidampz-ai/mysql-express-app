// Import required modules
const express = require('express');
const mysql = require('mysql2/promise');
const morgan = require('morgan');
const winston = require('winston');

// Initialize Express application
const app = express();

// Configure Winston logger for application logging
const logger = winston.createLogger({
  // Set logging level
  level: 'info',
  // Define log format as JSON
  format: winston.format.json(),
  // Define where to write logs
  transports: [
    // Write all logs to console
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    // Write all logs to combined.log file
    new winston.transports.File({ filename: 'logs/combined.log' }),
    // Write only error logs to error.log file
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' })
  ]
});

// Middleware to parse JSON request bodies
app.use(express.json());

// HTTP request logger middleware
app.use(morgan('combined'));

// Database configuration object
const dbConfig = {
  host: process.env.DB_HOST || 'mysql',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'rootpassword',
  database: process.env.DB_NAME || 'school_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

// Create a connection pool for database operations
let pool;

// Initialize database connection pool
const initializeDatabase = async () => {
  try {
    // Create connection pool
    pool = mysql.createPool(dbConfig);
    // Test the connection
    await pool.query('SELECT 1');
    logger.info('✅ Database connection pool established successfully');
  } catch (error) {
    logger.error('❌ Failed to connect to database:', error);
    // Retry connection after 5 seconds
    setTimeout(initializeDatabase, 5000);
  }
};

// ==============================================
// ENDPOINT 1: Simple SELECT with WHERE clause
// ==============================================
// Get all students from a specific grade
app.get('/api/students/grade/:grade', async (req, res) => {
  try {
    // Extract grade parameter from URL
    const { grade } = req.params;
    
    logger.info(`Fetching students from grade: ${grade}`);
    
    // Simple SELECT query with WHERE clause
    const query = `
      SELECT 
        student_id,
        first_name,
        last_name,
        email,
        grade,
        enrollment_date
      FROM students
      WHERE grade = ?
      ORDER BY last_name, first_name
    `;
    
    // Execute query with parameterized value to prevent SQL injection
    const [rows] = await pool.query(query, [grade]);
    
    // Log successful query execution
    logger.info(`Found ${rows.length} students in grade ${grade}`);
    
    // Send response with data
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    // Log error details
    logger.error('Error fetching students by grade:', error);
    // Send error response
    res.status(500).json({
      success: false,
      error: 'Failed to fetch students'
    });
  }
});

// ==============================================
// ENDPOINT 2: INNER JOIN - Students with their enrollments
// ==============================================
// Get students with their course enrollments
app.get('/api/students/:studentId/enrollments', async (req, res) => {
  try {
    // Extract student ID from URL parameters
    const { studentId } = req.params;
    
    logger.info(`Fetching enrollments for student ID: ${studentId}`);
    
    // INNER JOIN query - only returns students who have enrollments
    const query = `
      SELECT 
        s.student_id,
        s.first_name,
        s.last_name,
        c.course_id,
        c.course_name,
        c.credits,
        e.enrollment_date,
        e.grade
      FROM students s
      INNER JOIN enrollments e ON s.student_id = e.student_id
      INNER JOIN courses c ON e.course_id = c.course_id
      WHERE s.student_id = ?
      ORDER BY e.enrollment_date DESC
    `;
    
    // Execute query with student ID parameter
    const [rows] = await pool.query(query, [studentId]);
    
    logger.info(`Found ${rows.length} enrollments for student ${studentId}`);
    
    // Return results
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching student enrollments:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch enrollments'
    });
  }
});

// ==============================================
// ENDPOINT 3: LEFT JOIN - All students with optional enrollments
// ==============================================
// Get all students including those without enrollments
app.get('/api/students/all-with-enrollments', async (req, res) => {
  try {
    logger.info('Fetching all students with enrollment data');
    
    // LEFT JOIN - returns all students even if they have no enrollments
    const query = `
      SELECT 
        s.student_id,
        s.first_name,
        s.last_name,
        s.grade,
        COUNT(e.enrollment_id) as total_enrollments,
        GROUP_CONCAT(c.course_name SEPARATOR ', ') as courses
      FROM students s
      LEFT JOIN enrollments e ON s.student_id = e.student_id
      LEFT JOIN courses c ON e.course_id = c.course_id
      GROUP BY s.student_id, s.first_name, s.last_name, s.grade
      ORDER BY s.last_name
    `;
    
    // Execute query without parameters
    const [rows] = await pool.query(query);
    
    logger.info(`Found ${rows.length} students with enrollment data`);
    
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching students with enrollments:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch data'
    });
  }
});

// ==============================================
// ENDPOINT 4: GROUP BY with COUNT - Student count per grade
// ==============================================
// Get count of students in each grade
app.get('/api/analytics/students-per-grade', async (req, res) => {
  try {
    logger.info('Calculating students per grade');
    
    // GROUP BY query with aggregate function COUNT
    const query = `
      SELECT 
        grade,
        COUNT(*) as student_count,
        COUNT(DISTINCT email) as unique_emails
      FROM students
      GROUP BY grade
      ORDER BY grade
    `;
    
    const [rows] = await pool.query(query);
    
    logger.info(`Calculated distribution across ${rows.length} grades`);
    
    res.json({
      success: true,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error calculating students per grade:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to calculate analytics'
    });
  }
});

// ==============================================
// ENDPOINT 5: GROUP BY with HAVING - Courses with many students
// ==============================================
// Get courses that have more than a specified number of enrollments
app.get('/api/courses/popular/:minEnrollments', async (req, res) => {
  try {
    // Extract minimum enrollments threshold from URL
    const { minEnrollments } = req.params;
    
    logger.info(`Fetching courses with at least ${minEnrollments} enrollments`);
    
    // GROUP BY with HAVING clause to filter aggregated results
    const query = `
      SELECT 
        c.course_id,
        c.course_name,
        c.credits,
        COUNT(e.enrollment_id) as enrollment_count,
        AVG(CASE 
          WHEN e.grade = 'A' THEN 4.0
          WHEN e.grade = 'B' THEN 3.0
          WHEN e.grade = 'C' THEN 2.0
          WHEN e.grade = 'D' THEN 1.0
          ELSE 0.0
        END) as average_gpa
      FROM courses c
      INNER JOIN enrollments e ON c.course_id = e.course_id
      GROUP BY c.course_id, c.course_name, c.credits
      HAVING COUNT(e.enrollment_id) >= ?
      ORDER BY enrollment_count DESC, average_gpa DESC
    `;
    
    const [rows] = await pool.query(query, [parseInt(minEnrollments)]);
    
    logger.info(`Found ${rows.length} popular courses`);
    
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching popular courses:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch popular courses'
    });
  }
});

// ==============================================
// ENDPOINT 6: Complex JOIN with WHERE and GROUP BY
// ==============================================
// Get student performance summary with filtering
app.get('/api/analytics/student-performance', async (req, res) => {
  try {
    // Extract query parameters with defaults
    const minGPA = parseFloat(req.query.minGPA) || 0;
    const grade = req.query.grade;
    
    logger.info(`Fetching student performance data (minGPA: ${minGPA}, grade: ${grade || 'all'})`);
    
    // Complex query with multiple JOINs, WHERE, and GROUP BY
    const query = `
      SELECT 
        s.student_id,
        s.first_name,
        s.last_name,
        s.grade as student_grade,
        COUNT(e.enrollment_id) as courses_taken,
        SUM(c.credits) as total_credits,
        AVG(CASE 
          WHEN e.grade = 'A' THEN 4.0
          WHEN e.grade = 'B' THEN 3.0
          WHEN e.grade = 'C' THEN 2.0
          WHEN e.grade = 'D' THEN 1.0
          WHEN e.grade = 'F' THEN 0.0
        END) as gpa,
        GROUP_CONCAT(
          CONCAT(c.course_name, ' (', e.grade, ')')
          ORDER BY e.enrollment_date DESC
          SEPARATOR ' | '
        ) as course_history
      FROM students s
      INNER JOIN enrollments e ON s.student_id = e.student_id
      INNER JOIN courses c ON e.course_id = c.course_id
      WHERE 1=1
        ${grade ? 'AND s.grade = ?' : ''}
      GROUP BY s.student_id, s.first_name, s.last_name, s.grade
      HAVING AVG(CASE 
        WHEN e.grade = 'A' THEN 4.0
        WHEN e.grade = 'B' THEN 3.0
        WHEN e.grade = 'C' THEN 2.0
        WHEN e.grade = 'D' THEN 1.0
        WHEN e.grade = 'F' THEN 0.0
      END) >= ?
      ORDER BY gpa DESC, total_credits DESC
    `;
    
    // Build parameters array based on whether grade filter is applied
    const params = grade ? [grade, minGPA] : [minGPA];
    
    const [rows] = await pool.query(query, params);
    
    logger.info(`Found ${rows.length} students meeting performance criteria`);
    
    res.json({
      success: true,
      filters: {
        minGPA,
        grade: grade || 'all'
      },
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching student performance:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch performance data'
    });
  }
});

// ==============================================
// ENDPOINT 7: Subquery with WHERE IN
// ==============================================
// Get students enrolled in specific courses
app.get('/api/students/in-courses', async (req, res) => {
  try {
    // Extract course IDs from query parameter (comma-separated)
    const courseIds = req.query.courseIds?.split(',') || [];
    
    if (courseIds.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Please provide courseIds as comma-separated values'
      });
    }
    
    logger.info(`Fetching students in courses: ${courseIds.join(', ')}`);
    
    // Subquery to find students enrolled in specified courses
    const query = `
      SELECT DISTINCT
        s.student_id,
        s.first_name,
        s.last_name,
        s.email,
        s.grade,
        (
          SELECT COUNT(*)
          FROM enrollments e2
          WHERE e2.student_id = s.student_id
            AND e2.course_id IN (?)
        ) as matching_course_count
      FROM students s
      WHERE s.student_id IN (
        SELECT DISTINCT student_id
        FROM enrollments
        WHERE course_id IN (?)
      )
      ORDER BY matching_course_count DESC, s.last_name
    `;
    
    const [rows] = await pool.query(query, [courseIds, courseIds]);
    
    logger.info(`Found ${rows.length} students enrolled in specified courses`);
    
    res.json({
      success: true,
      courseIds,
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching students in courses:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch students'
    });
  }
});

// ==============================================
// ENDPOINT 8: Advanced - Multiple JOINs with CASE statements
// ==============================================
// Get comprehensive course analytics
app.get('/api/analytics/course-details/:courseId', async (req, res) => {
  try {
    const { courseId } = req.params;
    
    logger.info(`Fetching comprehensive analytics for course: ${courseId}`);
    
    // Advanced query with multiple JOINs, CASE statements, and aggregations
    const query = `
      SELECT 
        c.course_id,
        c.course_name,
        c.credits,
        c.department,
        COUNT(DISTINCT e.student_id) as total_students,
        COUNT(DISTINCT s.grade) as grade_levels_represented,
        -- Grade distribution
        SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) as count_A,
        SUM(CASE WHEN e.grade = 'B' THEN 1 ELSE 0 END) as count_B,
        SUM(CASE WHEN e.grade = 'C' THEN 1 ELSE 0 END) as count_C,
        SUM(CASE WHEN e.grade = 'D' THEN 1 ELSE 0 END) as count_D,
        SUM(CASE WHEN e.grade = 'F' THEN 1 ELSE 0 END) as count_F,
        -- Calculate percentages
        ROUND(SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as percent_A,
        ROUND(SUM(CASE WHEN e.grade = 'B' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as percent_B,
        -- Average GPA
        ROUND(AVG(CASE 
          WHEN e.grade = 'A' THEN 4.0
          WHEN e.grade = 'B' THEN 3.0
          WHEN e.grade = 'C' THEN 2.0
          WHEN e.grade = 'D' THEN 1.0
          WHEN e.grade = 'F' THEN 0.0
        END), 2) as average_gpa,
        -- Latest enrollment date
        MAX(e.enrollment_date) as latest_enrollment,
        -- Top performing student
        (
          SELECT CONCAT(s2.first_name, ' ', s2.last_name)
          FROM students s2
          INNER JOIN enrollments e2 ON s2.student_id = e2.student_id
          WHERE e2.course_id = c.course_id
            AND e2.grade = 'A'
          LIMIT 1
        ) as top_student_example
      FROM courses c
      LEFT JOIN enrollments e ON c.course_id = e.course_id
      LEFT JOIN students s ON e.student_id = s.student_id
      WHERE c.course_id = ?
      GROUP BY c.course_id, c.course_name, c.credits, c.department
    `;
    
    const [rows] = await pool.query(query, [courseId]);
    
    if (rows.length === 0) {
      logger.warn(`Course not found: ${courseId}`);
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }
    
    logger.info(`Successfully fetched analytics for course ${courseId}`);
    
    res.json({
      success: true,
      data: rows[0]
    });
    
  } catch (error) {
    logger.error('Error fetching course analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch course analytics'
    });
  }
});

// ==============================================
// ENDPOINT 9: Complex aggregation with HAVING and multiple conditions
// ==============================================
// Find high-performing students in multiple courses
app.get('/api/analytics/top-performers', async (req, res) => {
  try {
    // Extract parameters with validation
    const minCourses = parseInt(req.query.minCourses) || 3;
    const minGPA = parseFloat(req.query.minGPA) || 3.5;
    
    logger.info(`Fetching top performers (minCourses: ${minCourses}, minGPA: ${minGPA})`);
    
    // Complex query with multiple GROUP BY, HAVING clauses
    const query = `
      SELECT 
        s.student_id,
        s.first_name,
        s.last_name,
        s.email,
        s.grade as student_grade,
        COUNT(DISTINCT e.course_id) as courses_completed,
        SUM(c.credits) as total_credits_earned,
        -- Calculate weighted GPA
        ROUND(
          SUM(
            CASE 
              WHEN e.grade = 'A' THEN 4.0 * c.credits
              WHEN e.grade = 'B' THEN 3.0 * c.credits
              WHEN e.grade = 'C' THEN 2.0 * c.credits
              WHEN e.grade = 'D' THEN 1.0 * c.credits
              WHEN e.grade = 'F' THEN 0.0 * c.credits
            END
          ) / SUM(c.credits),
          2
        ) as weighted_gpa,
        -- Count of A grades
        SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) as a_count,
        -- Performance rating
        CASE 
          WHEN AVG(CASE 
            WHEN e.grade = 'A' THEN 4.0
            WHEN e.grade = 'B' THEN 3.0
            WHEN e.grade = 'C' THEN 2.0
            WHEN e.grade = 'D' THEN 1.0
            WHEN e.grade = 'F' THEN 0.0
          END) >= 3.8 THEN 'Outstanding'
          WHEN AVG(CASE 
            WHEN e.grade = 'A' THEN 4.0
            WHEN e.grade = 'B' THEN 3.0
            WHEN e.grade = 'C' THEN 2.0
            WHEN e.grade = 'D' THEN 1.0
            WHEN e.grade = 'F' THEN 0.0
          END) >= 3.5 THEN 'Excellent'
          WHEN AVG(CASE 
            WHEN e.grade = 'A' THEN 4.0
            WHEN e.grade = 'B' THEN 3.0
            WHEN e.grade = 'C' THEN 2.0
            WHEN e.grade = 'D' THEN 1.0
            WHEN e.grade = 'F' THEN 0.0
          END) >= 3.0 THEN 'Good'
          ELSE 'Satisfactory'
        END as performance_rating
      FROM students s
      INNER JOIN enrollments e ON s.student_id = e.student_id
      INNER JOIN courses c ON e.course_id = c.course_id
      GROUP BY s.student_id, s.first_name, s.last_name, s.email, s.grade
      HAVING 
        COUNT(DISTINCT e.course_id) >= ?
        AND ROUND(
          SUM(
            CASE 
              WHEN e.grade = 'A' THEN 4.0 * c.credits
              WHEN e.grade = 'B' THEN 3.0 * c.credits
              WHEN e.grade = 'C' THEN 2.0 * c.credits
              WHEN e.grade = 'D' THEN 1.0 * c.credits
              WHEN e.grade = 'F' THEN 0.0 * c.credits
            END
          ) / SUM(c.credits),
          2
        ) >= ?
      ORDER BY weighted_gpa DESC, courses_completed DESC
      LIMIT 20
    `;
    
    const [rows] = await pool.query(query, [minCourses, minGPA]);
    
    logger.info(`Found ${rows.length} top-performing students`);
    
    res.json({
      success: true,
      criteria: {
        minCourses,
        minGPA
      },
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching top performers:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch top performers'
    });
  }
});

// ==============================================
// ENDPOINT 10: Department analytics with nested aggregations
// ==============================================
// Get comprehensive department statistics
app.get('/api/analytics/departments', async (req, res) => {
  try {
    logger.info('Fetching department analytics');
    
    // Advanced query with subqueries and window functions simulation
    const query = `
      SELECT 
        c.department,
        COUNT(DISTINCT c.course_id) as total_courses,
        COUNT(DISTINCT e.student_id) as total_students,
        SUM(c.credits) as total_credits_offered,
        AVG(c.credits) as avg_credits_per_course,
        -- Enrollment statistics
        COUNT(e.enrollment_id) as total_enrollments,
        ROUND(COUNT(e.enrollment_id) * 1.0 / COUNT(DISTINCT c.course_id), 2) as avg_enrollments_per_course,
        -- Performance metrics
        ROUND(AVG(CASE 
          WHEN e.grade = 'A' THEN 4.0
          WHEN e.grade = 'B' THEN 3.0
          WHEN e.grade = 'C' THEN 2.0
          WHEN e.grade = 'D' THEN 1.0
          WHEN e.grade = 'F' THEN 0.0
        END), 2) as department_avg_gpa,
        -- Grade distribution
        CONCAT(
          'A:', SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END), ' ',
          'B:', SUM(CASE WHEN e.grade = 'B' THEN 1 ELSE 0 END), ' ',
          'C:', SUM(CASE WHEN e.grade = 'C' THEN 1 ELSE 0 END)
        ) as grade_distribution,
        -- Success rate (C or better)
        ROUND(
          SUM(CASE WHEN e.grade IN ('A', 'B', 'C') THEN 1 ELSE 0 END) * 100.0 / COUNT(e.enrollment_id),
          2
        ) as success_rate_percent
      FROM courses c
      LEFT JOIN enrollments e ON c.course_id = e.course_id
      GROUP BY c.department
      HAVING COUNT(e.enrollment_id) > 0
      ORDER BY total_enrollments DESC, department_avg_gpa DESC
    `;
    
    const [rows] = await pool.query(query);
    
    logger.info(`Fetched analytics for ${rows.length} departments`);
    
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
    
  } catch (error) {
    logger.error('Error fetching department analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch department analytics'
    });
  }
});

// ==============================================
// Health check endpoint
// ==============================================
app.get('/health', async (req, res) => {
  try {
    // Test database connection
    await pool.query('SELECT 1');
    res.json({
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Health check failed:', error);
    res.status(503).json({
      status: 'unhealthy',
      database: 'disconnected',
      error: error.message
    });
  }
});

// ==============================================
// Root endpoint with API documentation
// ==============================================
app.get('/', (req, res) => {
  res.json({
    message: 'MySQL Express API - SQL Query Examples',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      simple_where: 'GET /api/students/grade/:grade',
      inner_join: 'GET /api/students/:studentId/enrollments',
      left_join: 'GET /api/students/all-with-enrollments',
      group_by: 'GET /api/analytics/students-per-grade',
      having: 'GET /api/courses/popular/:minEnrollments',
      complex_join: 'GET /api/analytics/student-performance?minGPA=3.0&grade=10',
      subquery: 'GET /api/students/in-courses?courseIds=1,2,3',
      advanced_case: 'GET /api/analytics/course-details/:courseId',
      complex_aggregation: 'GET /api/analytics/top-performers?minCourses=3&minGPA=3.5',
      department_analytics: 'GET /api/analytics/departments'
    }
  });
});

// ==============================================
// Start server
// ==============================================
const PORT = process.env.PORT || 3000;

// Initialize database and start server
initializeDatabase().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    logger.info(`🚀 Server is running on port ${PORT}`);
    logger.info(`📚 API Documentation available at http://localhost:${PORT}/`);
  });
});

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  if (pool) {
    await pool.end();
    logger.info('Database pool closed');
  }
  process.exit(0);
});
