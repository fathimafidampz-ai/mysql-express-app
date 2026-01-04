-- ==========================================
-- Database Initialization Script
-- ==========================================
-- This script creates the database schema and populates it with sample data

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS school_db;

-- Use the school database
USE school_db;

-- ==========================================
-- DROP existing tables if they exist (for clean setup)
-- ==========================================
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- ==========================================
-- CREATE STUDENTS TABLE
-- ==========================================
-- Stores student information
CREATE TABLE students (
  -- Primary key: unique identifier for each student
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  -- Student's first name
  first_name VARCHAR(50) NOT NULL,
  -- Student's last name
  last_name VARCHAR(50) NOT NULL,
  -- Student's email address (must be unique)
  email VARCHAR(100) NOT NULL UNIQUE,
  -- Grade level (9-12 for high school)
  grade INT NOT NULL,
  -- Date when student enrolled in the school
  enrollment_date DATE NOT NULL,
  -- Timestamp for record creation
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Timestamp for record updates
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  -- Add index on grade for faster queries
  INDEX idx_grade (grade),
  -- Add index on email for faster lookups
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- CREATE COURSES TABLE
-- ==========================================
-- Stores course information
CREATE TABLE courses (
  -- Primary key: unique identifier for each course
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  -- Course name/title
  course_name VARCHAR(100) NOT NULL,
  -- Department offering the course
  department VARCHAR(50) NOT NULL,
  -- Number of credits for the course
  credits INT NOT NULL,
  -- Course description
  description TEXT,
  -- Timestamp for record creation
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Add index on department for faster queries
  INDEX idx_department (department)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- CREATE ENROLLMENTS TABLE
-- ==========================================
-- Junction table linking students to courses with grades
CREATE TABLE enrollments (
  -- Primary key: unique identifier for each enrollment
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  -- Foreign key: reference to student
  student_id INT NOT NULL,
  -- Foreign key: reference to course
  course_id INT NOT NULL,
  -- Date when student enrolled in the course
  enrollment_date DATE NOT NULL,
  -- Grade received in the course (A, B, C, D, F, or NULL if in progress)
  grade CHAR(1),
  -- Timestamp for record creation
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Foreign key constraint to students table
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  -- Foreign key constraint to courses table
  FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
  -- Prevent duplicate enrollments
  UNIQUE KEY unique_enrollment (student_id, course_id),
  -- Add composite index for common queries
  INDEX idx_student_course (student_id, course_id),
  -- Add index on enrollment_date
  INDEX idx_enrollment_date (enrollment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- INSERT SAMPLE DATA: STUDENTS
-- ==========================================
-- Insert 20 students across different grades
INSERT INTO students (first_name, last_name, email, grade, enrollment_date) VALUES
-- Grade 9 students
('John', 'Smith', 'john.smith@school.edu', 9, '2023-09-01'),
('Emily', 'Johnson', 'emily.johnson@school.edu', 9, '2023-09-01'),
('Michael', 'Williams', 'michael.williams@school.edu', 9, '2023-09-01'),
('Sarah', 'Brown', 'sarah.brown@school.edu', 9, '2023-09-01'),

-- Grade 10 students
('David', 'Jones', 'david.jones@school.edu', 10, '2022-09-01'),
('Jessica', 'Garcia', 'jessica.garcia@school.edu', 10, '2022-09-01'),
('Daniel', 'Martinez', 'daniel.martinez@school.edu', 10, '2022-09-01'),
('Ashley', 'Rodriguez', 'ashley.rodriguez@school.edu', 10, '2022-09-01'),
('James', 'Wilson', 'james.wilson@school.edu', 10, '2022-09-01'),

-- Grade 11 students
('Jennifer', 'Anderson', 'jennifer.anderson@school.edu', 11, '2021-09-01'),
('Robert', 'Taylor', 'robert.taylor@school.edu', 11, '2021-09-01'),
('Maria', 'Thomas', 'maria.thomas@school.edu', 11, '2021-09-01'),
('Christopher', 'Moore', 'christopher.moore@school.edu', 11, '2021-09-01'),
('Amanda', 'Jackson', 'amanda.jackson@school.edu', 11, '2021-09-01'),

-- Grade 12 students
('Matthew', 'Martin', 'matthew.martin@school.edu', 12, '2020-09-01'),
('Michelle', 'Lee', 'michelle.lee@school.edu', 12, '2020-09-01'),
('Joshua', 'Perez', 'joshua.perez@school.edu', 12, '2020-09-01'),
('Laura', 'White', 'laura.white@school.edu', 12, '2020-09-01'),
('Andrew', 'Harris', 'andrew.harris@school.edu', 12, '2020-09-01'),
('Elizabeth', 'Clark', 'elizabeth.clark@school.edu', 12, '2020-09-01');

-- ==========================================
-- INSERT SAMPLE DATA: COURSES
-- ==========================================
-- Insert courses from different departments
INSERT INTO courses (course_name, department, credits, description) VALUES
-- Mathematics courses
('Algebra I', 'Mathematics', 4, 'Introduction to algebraic concepts and problem solving'),
('Geometry', 'Mathematics', 4, 'Study of shapes, sizes, and properties of space'),
('Algebra II', 'Mathematics', 4, 'Advanced algebraic concepts and functions'),
('Pre-Calculus', 'Mathematics', 4, 'Preparation for calculus with advanced functions'),
('Calculus AB', 'Mathematics', 5, 'Introduction to differential and integral calculus'),

-- Science courses
('Biology', 'Science', 4, 'Study of living organisms and life processes'),
('Chemistry', 'Science', 4, 'Study of matter, its properties, and reactions'),
('Physics', 'Science', 4, 'Study of matter, energy, and their interactions'),
('Environmental Science', 'Science', 3, 'Study of environmental systems and sustainability'),

-- English courses
('English 9', 'English', 3, 'Introduction to literature and composition'),
('English 10', 'English', 3, 'World literature and advanced writing'),
('English 11', 'English', 3, 'American literature and rhetorical analysis'),
('English 12', 'English', 3, 'British literature and college preparation'),

-- Social Studies courses
('World History', 'Social Studies', 3, 'Survey of world civilizations and cultures'),
('US History', 'Social Studies', 3, 'American history from colonial times to present'),
('Government', 'Social Studies', 3, 'Study of political systems and civic engagement'),

-- Arts courses
('Art I', 'Arts', 2, 'Introduction to visual arts and techniques'),
('Music Theory', 'Arts', 2, 'Study of musical notation, harmony, and composition'),

-- Physical Education
('Physical Education', 'PE', 1, 'Physical fitness and sports activities');

-- ==========================================
-- INSERT SAMPLE DATA: ENROLLMENTS
-- ==========================================
-- Create realistic enrollment patterns with varying grades

-- Student 1 (Grade 9) - Good student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2023-09-01', 'A'),  -- Algebra I
(1, 6, '2023-09-01', 'B'),  -- Biology
(1, 10, '2023-09-01', 'A'), -- English 9
(1, 14, '2023-09-01', 'B'), -- World History
(1, 17, '2023-09-01', 'A'); -- Art I

-- Student 2 (Grade 9) - Average student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(2, 1, '2023-09-01', 'B'),  -- Algebra I
(2, 6, '2023-09-01', 'C'),  -- Biology
(2, 10, '2023-09-01', 'B'), -- English 9
(2, 14, '2023-09-01', 'C'), -- World History
(2, 19, '2023-09-01', 'A'); -- PE

-- Student 3 (Grade 9) - Excellent student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(3, 1, '2023-09-01', 'A'),  -- Algebra I
(3, 6, '2023-09-01', 'A'),  -- Biology
(3, 10, '2023-09-01', 'A'), -- English 9
(3, 14, '2023-09-01', 'A'), -- World History
(3, 18, '2023-09-01', 'A'); -- Music Theory

-- Student 4 (Grade 9) - Struggling student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(4, 1, '2023-09-01', 'C'),  -- Algebra I
(4, 6, '2023-09-01', 'D'),  -- Biology
(4, 10, '2023-09-01', 'C'), -- English 9
(4, 14, '2023-09-01', 'C'); -- World History

-- Student 5 (Grade 10) - Good student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(5, 2, '2022-09-01', 'A'),  -- Geometry
(5, 7, '2022-09-01', 'B'),  -- Chemistry
(5, 11, '2022-09-01', 'A'), -- English 10
(5, 15, '2022-09-01', 'A'), -- US History
(5, 17, '2022-09-01', 'B'); -- Art I

-- Student 6 (Grade 10) - Excellent student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(6, 2, '2022-09-01', 'A'),  -- Geometry
(6, 7, '2022-09-01', 'A'),  -- Chemistry
(6, 11, '2022-09-01', 'A'), -- English 10
(6, 15, '2022-09-01', 'A'), -- US History
(6, 18, '2022-09-01', 'A'), -- Music Theory
(6, 19, '2022-09-01', 'A'); -- PE

-- Student 7 (Grade 10) - Average student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(7, 2, '2022-09-01', 'B'),  -- Geometry
(7, 7, '2022-09-01', 'C'),  -- Chemistry
(7, 11, '2022-09-01', 'B'), -- English 10
(7, 15, '2022-09-01', 'B'); -- US History

-- Student 8 (Grade 10)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(8, 2, '2022-09-01', 'B'),  -- Geometry
(8, 7, '2022-09-01', 'B'),  -- Chemistry
(8, 11, '2022-09-01', 'A'), -- English 10
(8, 15, '2022-09-01', 'B'), -- US History
(8, 19, '2022-09-01', 'A'); -- PE

-- Student 9 (Grade 10)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(9, 2, '2022-09-01', 'C'),  -- Geometry
(9, 6, '2022-09-01', 'B'),  -- Biology
(9, 11, '2022-09-01', 'B'), -- English 10
(9, 14, '2022-09-01', 'C'); -- World History

-- Student 10 (Grade 11) - Excellent student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(10, 3, '2021-09-01', 'A'), -- Algebra II
(10, 8, '2021-09-01', 'A'), -- Physics
(10, 12, '2021-09-01', 'A'), -- English 11
(10, 16, '2021-09-01', 'A'), -- Government
(10, 18, '2021-09-01', 'A'); -- Music Theory

-- Student 11 (Grade 11) - Good student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(11, 3, '2021-09-01', 'B'), -- Algebra II
(11, 8, '2021-09-01', 'A'), -- Physics
(11, 12, '2021-09-01', 'A'), -- English 11
(11, 16, '2021-09-01', 'B'), -- Government
(11, 19, '2021-09-01', 'A'); -- PE

-- Student 12 (Grade 11)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(12, 3, '2021-09-01', 'B'), -- Algebra II
(12, 7, '2021-09-01', 'B'), -- Chemistry
(12, 12, '2021-09-01', 'B'), -- English 11
(12, 16, '2021-09-01', 'A'); -- Government

-- Student 13 (Grade 11)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(13, 3, '2021-09-01', 'A'), -- Algebra II
(13, 8, '2021-09-01', 'B'), -- Physics
(13, 12, '2021-09-01', 'A'), -- English 11
(13, 16, '2021-09-01', 'A'), -- Government
(13, 17, '2021-09-01', 'A'); -- Art I

-- Student 14 (Grade 11)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(14, 3, '2021-09-01', 'C'), -- Algebra II
(14, 6, '2021-09-01', 'B'), -- Biology
(14, 12, '2021-09-01', 'B'), -- English 11
(14, 15, '2021-09-01', 'C'); -- US History

-- Student 15 (Grade 12) - Excellent student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(15, 4, '2020-09-01', 'A'), -- Pre-Calculus
(15, 5, '2020-09-01', 'A'), -- Calculus AB
(15, 8, '2020-09-01', 'A'), -- Physics
(15, 13, '2020-09-01', 'A'), -- English 12
(15, 16, '2020-09-01', 'A'), -- Government
(15, 9, '2020-09-01', 'A'); -- Environmental Science

-- Student 16 (Grade 12) - Excellent student
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(16, 4, '2020-09-01', 'A'), -- Pre-Calculus
(16, 5, '2020-09-01', 'A'), -- Calculus AB
(16, 8, '2020-09-01', 'A'), -- Physics
(16, 13, '2020-09-01', 'A'), -- English 12
(16, 16, '2020-09-01', 'A'); -- Government

-- Student 17 (Grade 12)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(17, 4, '2020-09-01', 'B'), -- Pre-Calculus
(17, 8, '2020-09-01', 'B'), -- Physics
(17, 13, '2020-09-01', 'A'), -- English 12
(17, 16, '2020-09-01', 'B'), -- Government
(17, 19, '2020-09-01', 'A'); -- PE

-- Student 18 (Grade 12)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(18, 4, '2020-09-01', 'B'), -- Pre-Calculus
(18, 7, '2020-09-01', 'A'), -- Chemistry
(18, 13, '2020-09-01', 'A'), -- English 12
(18, 16, '2020-09-01', 'A'), -- Government
(18, 17, '2020-09-01', 'B'); -- Art I

-- Student 19 (Grade 12)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(19, 4, '2020-09-01', 'C'), -- Pre-Calculus
(19, 7, '2020-09-01', 'B'), -- Chemistry
(19, 13, '2020-09-01', 'B'), -- English 12
(19, 16, '2020-09-01', 'C'); -- Government

-- Student 20 (Grade 12)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(20, 3, '2020-09-01', 'B'), -- Algebra II
(20, 7, '2020-09-01', 'B'), -- Chemistry
(20, 13, '2020-09-01', 'A'), -- English 12
(20, 15, '2020-09-01', 'B'), -- US History
(20, 18, '2020-09-01', 'A'); -- Music Theory

-- ==========================================
-- VERIFICATION QUERIES
-- ==========================================
-- Display summary of inserted data

-- Count students per grade
SELECT 
  grade, 
  COUNT(*) as student_count 
FROM students 
GROUP BY grade 
ORDER BY grade;

-- Count courses per department
SELECT 
  department, 
  COUNT(*) as course_count 
FROM courses 
GROUP BY department 
ORDER BY department;

-- Total enrollments
SELECT COUNT(*) as total_enrollments FROM enrollments;

-- Display a sample of students with their enrollments
SELECT 
  s.first_name,
  s.last_name,
  s.grade,
  COUNT(e.enrollment_id) as courses_enrolled
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name, s.grade
ORDER BY s.grade, s.last_name
LIMIT 10;

-- Display message
SELECT '✅ Database initialization completed successfully!' as message;
